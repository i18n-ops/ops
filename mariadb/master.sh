#!/usr/bin/env bash

set -ex

cd /etc/mysql/conf.d

echo "
[mysqld]
rpl_semi_sync_master_enabled=1
rpl_semi_sync_master_wait_point=AFTER_SYNC
" >semi_sync.cnf

systemctl restart mariadb

SQL="CREATE USER 'sync'@'%' IDENTIFIED BY '$MYSQL_PWD';\
GRANT ALL PRIVILEGES ON *.* TO 'sync'@'%';\
FLUSH PRIVILEGES;"

sudo -u mysql mysql -e "$SQL"
