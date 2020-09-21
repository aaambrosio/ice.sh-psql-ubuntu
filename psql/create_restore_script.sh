#!/bin/bash

. $PWD/ice.config

echo "Creating $dbname restore script STARTED"

printf "• creating directories.."
sudo mkdir -p $backup_dir$dbname
echo " OK✓"

printf "• creating RESTORE.sh.."
sudo cp db/RESTORE.sh $backup_dir$dbname/RESTORE.sh
sudo sed -i "s;{{dbname}};$dbname;g" $backup_dir$dbname/RESTORE.sh
sudo sed -i "s;{{psql_backup_user}};$psql_backup_user;g" $backup_dir$dbname/RESTORE.sh
sudo chmod -R 777 $backup_dir
echo " OK✓"

echo "DONE"