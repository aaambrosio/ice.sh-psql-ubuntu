#!/bin/bash

echo "RESTORE Script Running..."

sudo service postgresql restart
sudo -u postgres dropdb {{dbname}}
sudo -u postgres psql -c "CREATE DATABASE {{dbname}}"

start_datetime=$( date '+%F_%H:%M:%S' )
sudo -u postgres psql {{dbname}} < {{dbname}}.dmp
end_datetime=$( date '+%F_%H:%M:%S' )

sudo -u postgres psql -d {{dbname}} -c "GRANT CONNECT ON DATABASE {{dbname}} TO {{psql_backup_user}};" > /dev/null
sudo -u postgres psql -d {{dbname}} -c "GRANT USAGE ON SCHEMA public TO {{psql_backup_user}};" > /dev/null
sudo -u postgres psql -d {{dbname}} -c "GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO {{psql_backup_user}};" > /dev/null
sudo -u postgres psql -d {{dbname}} -c "GRANT SELECT ON ALL SEQUENCES IN SCHEMA PUBLIC TO {{psql_backup_user}};" > /dev/null

psql --version
echo "RESTORE TIME: $start_datetime TO $end_datetime"