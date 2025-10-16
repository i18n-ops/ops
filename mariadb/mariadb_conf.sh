#!/usr/bin/env bash

set -ex

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

cp -f mariadb.service /etc/systemd/system/
systemctl daemon-reload
rsync -av $DIR/os/ /

conf_d=/etc/mariadb/conf.d
rm -rf $conf_d
ln -s $DIR/os$conf_d $conf_d

touch /etc/mariadb/init.sql
chown -R mariadb:mariadb /etc/mariadb
SERVER_ID=1000$(hostname | sed 's/[^0-9]//g')

srv_cnf=mariadb.conf.d/50-server

sed -i "s/SERVER_ID/$SERVER_ID/g" /etc/mariadb/$srv_cnf.cnf

set -a
. /etc/ops/mariadb/*.env
set +a

conf_port() {
  sed -i "/^port\s*=\s*/c\\port=$MYSQL_PORT" /etc/mariadb/$1.cnf
}

conf_port $srv_cnf
conf_port mariadb

echo -e "[mysqld]\nreport_host=$(hostname)" >/etc/mariadb/mariadb.conf.d/host.cnf
grep -q '^mariadb' /etc/security/limits.conf || echo -e "\nmariadb soft nofile 108224\nmariadb hard nofile 108224" >>/etc/security/limits.conf
