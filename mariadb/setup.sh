#!/usr/bin/env bash

set -ex

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

if [ ! -f "/usr/local/mysql/bin/mariadb" ]; then
  ./down.sh
fi

cp -f mariadb.service /etc/systemd/system/
systemctl daemon-reload
rsync -av $DIR/os/ /

rm -rf /etc/mysql/conf.d/rocksdb.cnf
touch /etc/mysql/init.sql
chown -R mysql:mysql /etc/mysql
SERVER_ID=1000$(hostname | sed 's/[^0-9]//g')
sed -i "s/SERVER_ID/$SERVER_ID/g" /etc/mysql/mariadb.conf.d/50-server.cnf
direnv exec . $DIR/conf_port.sh

echo -e "[mysqld]\nreport_host=$(hostname)" >/etc/mysql/conf.d/host.cnf
grep -q '^mysql' /etc/security/limits.conf || echo -e "\nmysql soft nofile 108224\nmysql hard nofile 108224" >>/etc/security/limits.conf
