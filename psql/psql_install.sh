#!/bin/bash

. $PWD/ice.config

echo "PostgreSQL$psql_version installation STARTED"

printf "• downloading PSQL$psql_version keys.."
sudo bash -c "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -" &> /dev/null
echo " OK✓"

printf "• adding PostgreSQL$psql_version repository.."
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -sc)-pgdg main" > /etc/apt/sources.list.d/PostgreSQL.list'
sudo apt-get update > /dev/null
echo " OK✓"

printf "• installing postgresql-$psql_version.."
sudo apt-get install postgresql-$psql_version -y -qq > /dev/null
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$psql_pw';" > /dev/null
sudo -u postgres bash -c "echo ""host all all 0.0.0.0/0 trust"" &>>/etc/postgresql/$psql_version/main/pg_hba.conf"
sudo -u postgres bash -c "echo ""listen_addresses = \'*\'"" &>>/etc/postgresql/$psql_version/main/postgresql.conf"
sudo service postgresql restart

sudo apt-key del $(wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | gpg --with-fingerprint --with-colons - 2> /dev/null | awk -F: '$1 == "fpr" {print $10;}') > /dev/null
sudo rm /etc/apt/sources.list.d/PostgreSQL.list

echo " OK✓"

if [ ! "$psql_backup_user" = "" ] && [ ! "$psql_backup_pw" = "" ]; then
    printf "• creating read-only user.."
    sudo -u postgres psql -c "CREATE USER $psql_backup_user WITH PASSWORD '$psql_backup_pw';" > /dev/null
    sudo -u postgres psql -c "ALTER ROLE $psql_backup_user WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD '$psql_backup_pw';" > /dev/null

    sudo service postgresql restart
    echo " OK✓"
fi

if [ -n "$data_dir" ] && [ ! "$data_dir" = "/var/lib/" ]; then
    printf "• moving data directory.."
    sudo mkdir -p $data_dir
    sudo chmod 777 $data_dir
    sudo service postgresql stop
    sudo -u postgres bash -c "rsync -av /var/lib/postgresql $data_dir" > /dev/null
    sudo -u postgres bash -c "rm -rf /var/lib/postgresql/$psql_version/main"

    sudo sed -i "s;/var/lib/;$data_dir;g" /etc/postgresql/$psql_version/main/postgresql.conf

    sudo service postgresql start
    echo " OK✓"
fi

echo "DONE"