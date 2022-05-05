FROM debian:latest
# https://github.com/renskiy/cron-docker-image/tree/master/debian

ENV DEBIAN_FRONTEND noninteractive

#ENV TZ="Europe/Moscow"

RUN set -ex \
    && apt-get clean && apt-get update \
    && apt-get -y install lsb-release gnupg2 apt-utils wget
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get clean && apt-get update \
    && apt-get -y install postgresql-client-10 iputils-ping dnsutils \
    && apt-get -y install pgbadger moreutils nano

RUN apt-get -y install postfix mutt
COPY main.cf /etc/postfix/main.cf

RUN set -ex \
    && apt-get clean && apt-get update \
# install cron
    && apt-get install -y cron \
    && rm -rf /var/lib/apt/lists/* \
# making logging pipe
    && mkfifo --mode 0666 /var/log/cron.log \
# make pam_loginuid.so optional for cron
# see https://github.com/docker/docker/issues/5663#issuecomment-42550548
    && sed --regexp-extended --in-place \
    's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' \
    /etc/pam.d/cron

RUN apt-get clean all

COPY docker-entrypoint.sh /etc/cron.d/
COPY start-cron /usr/sbin/

# scripts for cron
COPY c_log_switch.sh /etc/cron.d/
COPY c_kill_idle.sh /etc/cron.d/
COPY c_kill_idle_in_trans.sh /etc/cron.d/
COPY c_analyze.sh /etc/cron.d/
COPY c_vacuum.sh /etc/cron.d/
COPY c_take_sample.sh /etc/cron.d/
COPY c_send_report.sh /etc/cron.d/
COPY c_resend_report.sh /etc/cron.d/
COPY c_send_pgbadger.sh /etc/cron.d/
COPY c_send_locks.sh /etc/cron.d/
COPY c_pgdump.sh /etc/cron.d/

# для send_report.sh
#RUN mkdir -p /pgdata
#VOLUME /pgdata

# для send_pgbadger.sh
RUN mkdir -p /pglog
VOLUME /pglog

# для рабочий каталог для файлов tasks
RUN mkdir -p /cronwork
RUN chmod 777 /cronwork
VOLUME /cronwork

WORKDIR /etc/cron.d

ENTRYPOINT ["/etc/cron.d/docker-entrypoint.sh"]

CMD ["start-cron"]
