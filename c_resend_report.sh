#!/bin/bash

FILEREPORT='/cronwork/pg_profile_daily.html'

if [[ -v MAILSMTP ]]; then

# MAILSMTP='smtp.inbox.ru:25'
cat ${FILEREPORT} | mutt -e 'set content_type = text/html' -e "set from=\"${MAILLOGIN}\"" -e "set realname=\"${MAILFROM}\"" \
    -e 'set smtp_authenticators="login"' -e "set smtp_url=smtp://\"${MAILLOGIN}\"@\"${MAILSMTP}\"" -e "set smtp_pass=\"${MAILPWD}\"" -e 'set ssl_starttls=yes' \
    -e 'set ssl_verify_dates=no' -e 'set ssl_verify_host=no' -s 'PostgreSQL Daily Report' "\"${MAILTO}\""

fi

if [[ -v MAILSMTPURL ]]; then

# MAILSMTPURL='smtp://10.42.161.197:25'
cat ${FILEREPORT} | mutt -e 'set ssl_starttls=no' -e 'set ssl_force_tls=no' -e 'set content_type = text/html' -e "set from=\"${MAILLOGIN}\"" \
    -e "set realname=\"${MAILFROM}\"" -e "set smtp_url=\"${MAILSMTPURL}\"" -s 'PostgreSQL Daily Report' "\"${MAILTO}\""

fi

echo "[pg_profile]  Send pg_profile Daily Report"
