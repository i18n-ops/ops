#!/usr/bin/env bash

set -ex

./master.sh

SQL="CREATE USER IF NOT EXISTS 'sync'@'%' IDENTIFIED BY '$MYSQL_PWD';\
GRANT ALL PRIVILEGES ON *.* TO 'sync'@'%';\
FLUSH PRIVILEGES;"

sudo -u mysql /usr/local/mysql/bin/mariadb -e "$SQL"
