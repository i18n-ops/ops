#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

cd /etc/mysql/conf.d

mariadb=/usr/local/mysql/bin/mariadb
IS_SLAVE=$(sudo -u mysql $mariadb -e "show slave status\G" | grep "Master_Host:" | wc -l)

if [ "$IS_SLAVE" -eq 0 ]; then
  MASTER_DEMOTE_TO_SLAVE="MASTER_DEMOTE_TO_SLAVE=1,"
fi

# MYSQL MASTER_AUTO_POSITION=1,
SQL="STOP SLAVE;\
CHANGE MASTER TO \
$MASTER_DEMOTE_TO_SLAVE \
master_use_gtid=slave_pos,\
MASTER_USER='sync',\
MASTER_HOST='$MYSQL_HOST',\
MASTER_PORT=$MYSQL_PORT,\
MASTER_PASSWORD='$MYSQL_PWD',\
MASTER_CONNECT_RETRY=1;
START SLAVE;
"

echo $SQL >/etc/mysql/init.sql
sudo -u mysql $mariadb </etc/mysql/init.sql
