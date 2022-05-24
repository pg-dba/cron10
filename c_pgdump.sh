#!/bin/bash
# need s3e image with directory backups mapped

backupDatabase=$1
#backupName="${backupDatabase}_$(date +%FT%T%z).dump"
backupName="${backupDatabase}_$(date +%A).dump"

echo "[pgdump]  [${backupDatabase}] backup started"

PGPASSWORD=${PASSWORD} pg_dump -h ${HOST} -p ${PORT} -U ${USERNAME} -Fc -f "/pgbackups/${backupName}" "${backupDatabase}" 2>&1
RC=$?

echo "[pgdump]  [${backupDatabase}] backup finished. RC=${RC}"
