#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

cd /etc/mysql/conf.d

# read_only=1
echo "
[mysqld]
rpl_semi_sync_slave_enabled=1
" >semi_sync.cnf

systemctl restart mariadb

SQL="CHANGE MASTER TO \
MASTER_HOST='$MYSQL_HOST', \
MASTER_USER='sync',\
MASTER_PASSWORD='$MYSQL_PWD';\
START SLAVE;"

echo $SQL
sudo -u mysql mysql -e "$SQL"
