#!/bin/bash

backup_dir="{{backup_dir}}{{dbname}}/BACKUP_`date '+%Y%m%d%H%M%S'`/"
backup_file_name={{dbname}}"_"`date '+%Y%m%d%H%M%S'`

mkdir -p $backup_dir
chmod 777 -R $backup_dir
PGPASSWORD="{{psql_backup_pw}}" pg_dump --no-owner -h localhost -p 5432 -U {{psql_backup_user}} {{dbname}} > $backup_dir$backup_file_name.dmp
chmod -R 777 $backup_dir