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

conf_d=/etc/mysql/conf.d
rm -rf $conf_d
ln -s $DIR/os$conf_d $conf_d

touch /etc/mysql/init.sql
chown -R mysql:mysql /etc/mysql
SERVER_ID=1000$(hostname | sed 's/[^0-9]//g')

srv_cnf=mariadb.conf.d/50-server

sed -i "s/SERVER_ID/$SERVER_ID/g" /etc/mysql/$srv_cnf.cnf

. /etc/ops/mariadb/conf.sh
. /etc/ops/mariadb/mariadb.sh

conf_port() {
  sed -i "/^port\s*=\s*/c\\port=$MARIADB_PORT" /etc/mysql/$1.cnf
}

conf_port $srv_cnf
conf_port mariadb

echo -e "[mysqld]\nreport_host=$(hostname)" >/etc/mysql/mariadb.conf.d/host.cnf
grep -q '^mysql' /etc/security/limits.conf || echo -e "\nmysql soft nofile 108224\nmysql hard nofile 108224" >>/etc/security/limits.conf

./initdb.sh
