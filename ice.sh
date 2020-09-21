#!/bin/bash

psql_version=12
backup_dir=/psql-backup/

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root, use 'sudo $0' instead" 1>&2
    exit 1
fi

. ice.config

if [ "$psql_version" = "" ]; then
    echo "psql_version not set in ice.config"
    exit 1
fi

if [ "$backup_dir" = "" ]; then
    echo "backup_dir not set in ice.config"
    exit 1
fi

arr_scripts=(psql_install.sh)

echo "Installation: PostgreSQL $psql_version"

if [ "$psql_pw" = "" ]; then
    printf "\n\nSet password for 'postgres': "
    read -s input_set_password_psql

    if [ "$input_set_password_psql" = "" ]; then
        printf "\n\nPassword cannot be empty.\nExiting..\n"
        exit 1
    fi

    printf "\nConfirm password for 'postgres': "
    read -s input_confirm_password

    if [ ! "$input_set_password_psql" = "$input_confirm_password" ]; then
        printf "\n\nPasswords did not match.\nExiting..\n"
        exit 1
    else
        psql_pw=$input_set_password_psql
    fi
fi

if [ "$restore_db" = "" ]; then
    printf "\n\nRestore pre-created database? [Y/n]: "
    read input_restore_db
    input_restore_db=${input_restore_db:-y}
    restore_db=$input_restore_db
else
    input_restore_db=$restore_db
fi

if [ "$input_restore_db" = "Y" ] || [ "$input_restore_db" = "y" ]; then
    if [ "$dbname" = "" ]; then
        printf "\nEnter database name: "
        read input_db_name

        dbname=$input_db_name
    fi

    if [ ! -f "db/$dbname.zip" ]; then
        printf "\n\n'db/$dbname.zip' does not exist\nExiting..\n"
        exit 1
    else
        arr_scripts[${#arr_scripts[@]}]=restore_db.sh
        arr_scripts[${#arr_scripts[@]}]=create_backup_script.sh
        set_restore_db=true
        printf "\n\n..'db/$dbname.zip' will be restored"
    fi
fi

if [ "$set_restore_db" = true ]; then
    if [ "$psql_backup_user" = "" ]; then
        printf "\nSet Backup username: "
        read input_backup_username

        if [ "$input_backup_username" = "" ]; then
            printf "\nBackup username cannot be empty.\nExiting..\n"
            exit 1
        fi

        psql_backup_user=$input_backup_username
    fi

    if [ ! "$psql_backup_user" = "" ] && [ "$psql_backup_pw" = "" ]; then
        printf "\nSet password for '$psql_backup_user': "
        read -s input_set_password_backup

        if [ "$input_set_password_backup" = "" ]; then
            printf "\n\nPassword cannot be empty.\nExiting..\n"
            exit 1
        fi

        printf "\nConfirm password for '$psql_backup_user': "
        read -s input_confirm_password_backup

        if [ ! "$input_set_password_backup" = "$input_confirm_password_backup" ]; then
            printf "\n\nPasswords did not match.\nExiting..\n"
            exit 1
        else
            psql_backup_pw=$input_set_password_backup
        fi
    fi
fi

if [ "$replication_setup" = "" ]; then
    printf "\n\nReplication setup: m=master, s=slave, n=skip  [m/s/N]: "
    read input_replication_setup
    input_replication_setup=${input_replication_setup:-n}

    replication_setup=$input_replication_setup
else
    input_replication_setup=$replication_setup
fi

case "$input_replication_setup" in
	M|m) printf "\n\n..Replication set to MASTER"
        arr_scripts[${#arr_scripts[@]}]=psql_replication_master.sh
        arr_scripts[${#arr_scripts[@]}]=create_restore_script.sh
        set_replication_credentials=true

        if [ "$replication_slave_ip" = "" ]; then
            printf "\nEnter Slave IP Addresses (comma separated): "
            read replication_slave_ip
        fi

        IFS=',' read -r -a arr_replication_slave_ip <<< "$replication_slave_ip"

        for i_slave_ip in "${arr_replication_slave_ip[@]}"
        do
            ping_replication_slave=$(ping -qc1 $i_slave_ip 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK":"FAIL") }')
            
            if [ "$ping_replication_slave" = "FAIL" ]; then
                printf "\n\nSlave IP $i_slave_ip is unreachable.\nExiting..\n"
                exit 1
            fi
        done

		;;
	S|s) printf "\n\n..Replication set to SLAVE"
        arr_scripts[${#arr_scripts[@]}]=psql_replication_slave.sh
        
        set_replication_credentials=true

        if [ "$replication_master_ip" = "" ]; then
            printf "\nEnter Master IP Address: "
            read replication_master_ip

            ping_replication_master=$(ping -qc1 $replication_master_ip 2>&1 | awk -F'/' 'END{ print (/^rtt/? "OK":"FAIL") }')
        fi

        if [ "$ping_replication_master" = "FAIL" ]; then
            printf "\n\Master IP $replication_master_ip is unreachable.\nExiting..\n"
            exit 1
        fi

		;;
	N|n|"") printf "\n\n..skipping Replication setup"
		;;
	*) printf "\nInvalid Replication setup input '$input_replication_setup'\nExiting..\n"
        exit 1
		;;
esac

if [ "$set_replication_credentials" = true ]; then
    if [ "$psql_replication_user" = "" ]; then
        printf "\nSet Replication username: "
        read input_replication_username

        if [ "$input_replication_username" = "" ]; then
            printf "\n\nReplication username cannot be empty.\nExiting..\n"
            exit 1
        fi

        psql_replication_user=$input_replication_username
    fi

    if [ ! "$psql_replication_user" = "" ] && [ "$psql_replication_pw" = "" ]; then
        printf "\nSet password for '$psql_replication_user': "
        read -s input_set_password_replication

        if [ "$input_set_password_replication" = "" ]; then
            printf "\n\nPassword cannot be empty.\nExiting..\n"
            exit 1
        fi

        printf "\nConfirm password for '$psql_replication_user': "
        read -s input_confirm_password_replication

        if [ ! "$input_set_password_replication" = "$input_confirm_password_replication" ]; then
            printf "\n\nPasswords did not match.\nExiting..\n"
            exit 1
        else
            psql_replication_pw=$input_set_password_replication
        fi
    fi
fi

if [ "$install_pgadmin" = "" ]; then
    printf "\n\nInstall pgAdmin4? [Y/n]: "
    read input_install_pgadmin
    input_install_pgadmin=${input_install_pgadmin:-y}
    install_pgadmin=$input_install_pgadmin
else
    input_install_pgadmin=$install_pgadmin
fi

if [ "$input_install_pgadmin" = "Y" ] || [ "$input_install_pgadmin" = "y" ]; then
    arr_scripts[${#arr_scripts[@]}]=pgadmin_install.sh
    install_pgadmin=y
    printf "\n\n..pgAdmin4 will be installed"
else
    printf "\n\n..pgAdmin4 will NOT be installed"
fi

printf "\n\nProceed with the following configurations?\n"

echo "backup_dir: $backup_dir"

if [ ! "$data_dir" = "" ]; then
    echo "data_dir: $data_dir"
else
    data_dir=/var/lib/
fi

if [ ! "$psql_backup_user" = "" ]; then
    echo "psql_backup_user: $psql_backup_user"
fi

if [ "$set_replication_credentials" = true ]; then
    echo "psql_replication_user: $psql_replication_user"

    case "$input_replication_setup" in
        M|m)
                echo "replication_setup: MASTER"
                echo "replication_slave_ip: $replication_slave_ip"
            ;;
        S|s)    echo "replication_setup: SLAVE"
                echo "replication_master_ip: $replication_master_ip"
            ;;
    esac
fi

if [ "$install_pgadmin" = "y" ]; then
    echo "install_pgadmin: YES"
fi

read -p "[Y/n]: " input_proceed_config
input_proceed_config=${input_proceed_config:-y}

if [ "$input_proceed_config" = "Y" ] || [ "$input_proceed_config" = "y" ]; then
    clear

    printf "\nSETUP STARTED\n"

    sudo rm ice.config

    sudo echo "psql_version=$psql_version" &>>ice.config
    sudo echo "backup_dir=$backup_dir" &>>ice.config
    sudo echo "data_dir=$data_dir" &>>ice.config
    sudo echo "psql_pw=$psql_pw" &>>ice.config
    sudo echo "restore_db=$restore_db" &>>ice.config
    sudo echo "dbname=$dbname" &>>ice.config
    sudo echo "psql_backup_user=$psql_backup_user" &>>ice.config
    sudo echo "psql_backup_pw=$psql_backup_pw" &>>ice.config
    sudo echo "replication_setup=$replication_setup" &>>ice.config
    sudo echo "psql_replication_user=$psql_replication_user" &>>ice.config
    sudo echo "psql_replication_pw=$psql_replication_pw" &>>ice.config
    sudo echo "replication_master_ip=$replication_master_ip" &>>ice.config
    sudo echo "replication_slave_ip=$replication_slave_ip" &>>ice.config
    sudo echo "install_pgadmin=$install_pgadmin" &>>ice.config

    sudo chmod -R 777 ice.config
    
    sudo chmod -R 777 psql

    for i_script in "${arr_scripts[@]}"
    do
        echo ""
        ./psql/$i_script
        echo ""
    done

    sudo sed -i "s;psql_pw=$psql_pw;psql_pw=;" ice.config
    sudo sed -i "s;psql_backup_pw=$psql_backup_pw;psql_backup_pw=;" ice.config
    sudo sed -i "s;psql_replication_pw=$psql_replication_pw;psql_replication_pw=;" ice.config

    printf "\nSETUP COMPLETED\n"
else
    printf "\n\nSetup cancelled.\nExiting..\n"
fi