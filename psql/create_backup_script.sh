#!/bin/bash

. $PWD/ice.config

echo "Creating $dbname backup script STARTED"

printf "• creating directories.."
sudo mkdir -p $backup_dir$dbname
echo " OK✓"

printf "• creating BACKUP.sh.."
sudo cp db/BACKUP.sh $backup_dir$dbname/BACKUP.sh
sudo sed -i "s;{{dbname}};$dbname;g" $backup_dir$dbname/BACKUP.sh
sudo sed -i "s;{{psql_backup_user}};$psql_backup_user;g" $backup_dir$dbname/BACKUP.sh
sudo sed -i "s;{{psql_backup_pw}};$psql_backup_pw;g" $backup_dir$dbname/BACKUP.sh
sudo sed -i "s;{{backup_dir}};$backup_dir;g" $backup_dir$dbname/BACKUP.sh
sudo chmod -R 777 $backup_dir
echo " OK✓"

echo "DONE"