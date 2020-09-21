# ice.sh: PostgreSQL > Linux Ubuntu
ice.sh - stands for Install, Configure and Execute via Shell. This `ice.sh` is for scripted installation and configuration of PostgreSQL in Linux Ubuntu.

## Script
Execute `ice.sh` to run. The script does the following:
- Installs PostgreSQL from repository
- Restores database after installation
- Configures Master/Slave Replication
- Installs pgAdmin4

## Configuration
Installation options and configuration parameters can be set by either or both of the following:
#### 1. Preset parameter values in `ice.config`
- Sample contents for `ice.config`:
```shell
# Sample configurations for Master server
psql_version=12
backup_dir=/psql-backup/
data_dir=/psql/data/
psql_pw=masterpass
restore_db=y
dbname=db_test
psql_backup_user=db_user_backup
psql_backup_pw=backuppass
replication_setup=m
psql_replication_user=db_user_replication
psql_replication_pw=replicationpass
replication_master_ip=
replication_slave_ip=192.168.0.124
install_pgadmin=y
```
```shell
# Sample configurations for Slave server
psql_version=12
backup_dir=/psql-backup/
data_dir=/psql/data/
psql_pw=masterpass
restore_db=n
dbname=
psql_backup_user=db_user_backup
psql_backup_pw=backuppass
replication_setup=s
psql_replication_user=db_user_replication
psql_replication_pw=replicationpass
replication_master_ip=192.168.0.123
replication_slave_ip=
install_pgadmin=y
```
- Descriptions of parameters in `ice.config`:
<br/>`psql_version`&nbsp; -&nbsp; Version of PostgreSQL to install. Default is `12`.
<br/>`backup_dir`&nbsp; -&nbsp; Directory to contain backup files. Default is `/psql-backup/`.
<br/>`data_dir`&nbsp; -&nbsp; PostgreSQL data directory. Default is `/var/lib/`.
<br/>`psql_pw`&nbsp; -&nbsp; Password for `postgres`&nbsp; user.
<br/>`restore_db`&nbsp; -&nbsp;&nbsp;`y`&nbsp; restore *pre-created database<sup>[1]</sup>*.&nbsp;`n`&nbsp; skip database restoration.
<br/>`dbname`&nbsp; -&nbsp; Database name of *pre-created database<sup>[1]</sup>*.
<br/>`psql_backup_user`&nbsp; -&nbsp; Read-only database user.
<br/>`psql_backup_pw`&nbsp; -&nbsp; Password for read-only database user.
<br/>`replication_setup`&nbsp; -&nbsp; &nbsp;`m`&nbsp; configure as Master.&nbsp;`s`&nbsp; configure as Slave.&nbsp;`n`&nbsp; skip replication setup.
<br/>`psql_replication_user`&nbsp; -&nbsp; Replication database user.
<br/>`psql_replication_pw`&nbsp; -&nbsp; Password for replication database user.
<br/>`replication_master_ip`&nbsp; -&nbsp; IP address of Master server.
<br/>`replication_slave_ip`&nbsp; -&nbsp; IP address of Slaver server.
<br/>`install_pgadmin`&nbsp; -&nbsp; &nbsp;`y`&nbsp; install pgAdmin4.&nbsp;`n`&nbsp; skip pgAdmin4 installation.

#### 2. Manual input of parameter values as needed.
- These video clips demonstrate the script being run with manually input parameters: [Master Server](https://drive.google.com/file/d/10oDdelMfECDZE6SbnzVPT7vk5YEvgEH2), [Slave Server](https://drive.google.com/file/d/1EH7KDGzlVt3oFezhOrDfitytP5EF_Ra2)

## Demo
 - Full demonstration video clip is [here](https://drive.google.com/file/d/1M15mghVgJXrrULFMS-qqutBvwXp72_jk).

## Citations
1. Pre-created Database - Pre-created `.dmp` file compressed as `.zip` saved in `db` folder. Dabatase name and filename should be the same. Example for `db_test` database name: `db/db_test.zip`
