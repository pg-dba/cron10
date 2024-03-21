#!/bin/bash
# c_pgdump_all.sh

logfile="/cronwork/PGDUMPALL.log";
fprefix="${HOST}_$(date '+%Y-%m-%d_%H-%M-%S_%z')"

# если параметр 1 и он только из цифр
if [[ ("$#" -eq 1) && ($1 =~ ^[[:digit:]]+$) ]]; then

IFS="|";
echo "===== ${HOST} PGDUMPALL started ====="  2>&1;
echo "===== $(date --iso-8601=seconds) PGDUMPALL started ====="  > ${logfile} 2>&1;

PGPASSWORD=${PASSWORD} pg_dumpall -h ${HOST} -p ${PORT} -U ${USERNAME} --schema-only -f "/pgbackups/${fprefix}_dumpall_full.sql" 2>&1
RC=$?
echo "[pgdump]  pg_dumpall schema-only finished. RC=${RC}"

PGPASSWORD=${PASSWORD} pg_dumpall -h ${HOST} -p ${PORT} -U ${USERNAME} --globals-only -f "/pgbackups/${fprefix}_dumpall_global.sql" 2>&1
RC=$?
echo "[pgdump]  pg_dumpall globals-only finished. RC=${RC}"

cmd1="SELECT datname FROM pg_database WHERE datistemplate = false;";
DBs=($(PGPASSWORD=${PASSWORD} psql -h ${HOST} -p ${PORT} -U ${USERNAME} -d postgres -c "${cmd1}" -XAt | tr -s '\n' '|' | tr -d '\r'));

for dbName in ${!DBs[*]}; do

PGPASSWORD=${PASSWORD} pg_dump -h ${HOST} -p ${PORT} -U ${USERNAME} -d ${DBs[$dbName]} --schema-only -f "/pgbackups/${fprefix}_${DBs[$dbName]}_schema-only.sql" >> ${logfile} 2>&1;
RC=$?
echo "[pgdump]  pg_dump db:${DBs[$dbName]} schema-only finished. RC=${RC}"

done;

find /pgbackups/ -name "${fprefix}*.sql" | tar czf /pgbackups/${fprefix}.tgz --files-from=- &>/dev/null;
#tar -tvf /pgbackups/${fprefix}.tgz &>/dev/null;
rm -f /pgbackups/${fprefix}*.sql

if [[ ("$#" -eq 1) ]]; then

saves=$1

rm -f $(ls -1t --time-style=long-iso /pgbackups/${HOST}_*.tgz 2>/dev/null | sed -n "$((${saves}+1)),\$p")

echo "[pgdump]  backup file $1 rotation completed."
fi

echo "===== $(date --iso-8601=seconds) PGDUMPALL finished =====" &>>${logfile};
echo "===== ${HOST} PGDUMPALL finished =====" 2>&1;

fi
