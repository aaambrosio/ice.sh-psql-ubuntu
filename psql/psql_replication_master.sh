#!/bin/bash

. $PWD/ice.config

echo "PostgreSQL$psql_version MASTER Replication setup STARTED"

printf "• creating replication user.."
sudo -u postgres psql -c "CREATE USER $psql_replication_user REPLICATION LOGIN ENCRYPTED PASSWORD '$psql_replication_pw';" > /dev/null
echo " OK✓"

printf "• creating archive directory.."
sudo -u postgres bash -c "mkdir ${data_dir}postgresql/$psql_version/main/archive"
echo " OK✓"

printf "• updating configurations.."

arr_replication_slave_ip=($replication_slave_ip)

for i_slave_ip in "${arr_replication_slave_ip[@]}"
do
    sudo -u postgres bash -c "echo 'host replication $psql_replication_user $i_slave_ip/32 md5' &>>/etc/postgresql/$psql_version/main/pg_hba.conf"
done

sudo -u postgres bash -c "echo 'wal_level = replica' &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo -u postgres bash -c "echo 'max_wal_senders = 4' &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo -u postgres bash -c "echo 'wal_keep_segments = 32' &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo -u postgres bash -c "echo 'archive_mode = on' &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo -u postgres bash -c "echo ""archive_command = \'cp -i %p ${data_dir}postgresql/$psql_version/main/archive/%f\'"" &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo service postgresql restart
echo " OK✓"

echo "DONE"