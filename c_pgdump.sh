#!/bin/bash
# need s3e image with directory backups mapped

dbName=$1	# DataBase Name
backupName="${dbName}_$(date +%FT%T%z).dump"

echo "[pgdump]  backup started"

pg_dump -Fc -U postgres -f /var/lib/postgresql/backups/${backupName} ${dbName} 2>&1
RC=$?

echo "[pgdump]  backup finished. RC=${RC}"
