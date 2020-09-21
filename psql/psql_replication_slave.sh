#!/bin/bash

. $PWD/ice.config

echo "PostgreSQL$psql_version SLAVE Replication setup STARTED"

printf "• updating configurations.."
sudo -u postgres bash -c "echo 'wal_keep_segments = 32' &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo -u postgres bash -c "echo 'wal_level = replica' &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo -u postgres bash -c "echo 'hot_standby = on' &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo -u postgres bash -c "echo 'wal_log_hints = on' &>>/etc/postgresql/$psql_version/main/postgresql.conf"
echo " OK✓"

printf "• deleting data directory.."
sudo -u postgres bash -c "rm -rf ${data_dir}postgresql/$psql_version/main/"
echo " OK✓"

printf "• syncing data with Master.."
sudo -u postgres bash -c "echo ""$replication_master_ip:5432:*:$psql_replication_user:$psql_replication_pw"" > /var/lib/postgresql/.pgpass"
sudo chown postgres:postgres /var/lib/postgresql/.pgpass
sudo chmod 0600 /var/lib/postgresql/.pgpass
sudo -u postgres bash -c "pg_basebackup -h $replication_master_ip -U $psql_replication_user -p 5432 -D ${data_dir}postgresql/$psql_version/main -R"
sudo sleep 100
sudo -u postgres bash -c "touch ${data_dir}postgresql/$psql_version/main/standby.signal"
sudo service postgresql restart
echo " OK✓"

echo "DONE"