#!/usr/bin/env bash

if [ -n "$1" ]; then
  export MASTER_IP=$1
else
  echo "USAGE : $0 MASTER_IP"
  exit 1
fi

. /etc/ops/mariadb/conf.sh
. /etc/ops/mariadb/mariadb.sh

set -ex
mariadb="sudo -u mariadb /usr/local/mariadb/bin/mariadb"

IS_SLAVE=$($mariadb -e "SHOW SLAVE STATUS\G" | grep "Master_Host:" | wc -l)

if [ "$IS_SLAVE" -eq 0 ]; then
  MASTER_DEMOTE_TO_SLAVE="MASTER_DEMOTE_TO_SLAVE=1,"
fi

# MYSQL MASTER_AUTO_POSITION=1,

$mariadb -e "STOP SLAVE;\
SET GLOBAL read_only=ON;\
RESET SLAVE ALL;\
RESET MASTER;\
CHANGE MASTER TO \
$MASTER_DEMOTE_TO_SLAVE \
master_use_gtid=slave_pos,\
MASTER_USER='sync',\
MASTER_HOST='$MASTER_IP',\
MASTER_PORT=$MYSQL_PORT,\
MASTER_PASSWORD='$MYSQL_PWD',\
MASTER_CONNECT_RETRY=1;\
START SLAVE;"
