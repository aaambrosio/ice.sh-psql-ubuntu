#!/bin/bash

. $PWD/ice.config

echo "Creating $dbname database STARTED"

printf "• extracting $dbname.."
sudo mkdir -p $backup_dir$dbname
sudo unzip -q db/$dbname.zip -d $backup_dir$dbname
sudo chmod 777 db/$dbname.zip
echo " OK✓"

printf "• restoring $dbname.."
sudo chmod -R 777 $backup_dir
sudo service postgresql restart
sudo -u postgres psql -c "CREATE DATABASE $dbname;" > /dev/null
sudo -u postgres bash -c "psql $dbname < $backup_dir$dbname/$dbname.dmp &> /dev/null"
echo " OK✓"

printf "• grant $psql_backup_user access to $dbname.."
sudo -u postgres psql -d $dbname -c "GRANT CONNECT ON DATABASE ""$dbname"" TO $psql_backup_user;" > /dev/null
sudo -u postgres psql -d $dbname -c "GRANT USAGE ON SCHEMA public TO $psql_backup_user;" > /dev/null
sudo -u postgres psql -d $dbname -c "GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO $psql_backup_user;" > /dev/null
sudo -u postgres psql -d $dbname -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA PUBLIC TO $psql_backup_user;" > /dev/null
echo " OK✓"

echo "DONE"