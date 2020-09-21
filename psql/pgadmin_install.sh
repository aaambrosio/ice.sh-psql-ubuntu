#!/bin/bash

echo "pgAdmin4 installation STARTED"

printf "• downloading pgAdmin4 keys.."
sudo bash -c "wget --quiet -O - https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add -" &> /dev/null
echo " OK✓"

printf "• adding pgAdmin4 repository.."
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list' > /dev/null
sudo apt-get update > /dev/null
echo " OK✓"

printf "• installing pgadmin4-desktop.."
sudo apt-get install pgadmin4-desktop -y -qq > /dev/null

sudo apt-key del $(wget -q https://www.pgadmin.org/static/packages_pgadmin_org.pub -O- | gpg --with-fingerprint --with-colons - 2> /dev/null | awk -F: '$1 == "fpr" {print $10;}') > /dev/null
sudo rm /etc/apt/sources.list.d/pgadmin4.list

echo " OK✓"

echo "DONE"