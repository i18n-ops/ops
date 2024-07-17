#!/usr/bin/env bash

# 从库不需要用运行

SQL="CREATE DATABASE IF NOT EXISTS $MYSQL_DB DEFAULT CHARACTER SET binary;\
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PWD';\
GRANT ALL PRIVILEGES ON $MYSQL_DB.* TO '$MYSQL_USER'@'%';\
GRANT CREATE ROUTINE ON $MYSQL_DB.* TO '$MYSQL_USER'@'%';
GRANT SUPER ON *.* TO '$MYSQL_USER'@'%';
DROP DATABASE IF EXISTS test;\
FLUSH PRIVILEGES;"

sudo -u mysql /usr/local/mysql/bin/mariadb -e "$SQL"
