#!/usr/bin/env bash

set -ex

DIR=$(realpath $0) && DIR=${DIR%/*}

apt-get install -y libaio1
source $DIR/VER.sh

mkdir -p /tmp/mariadb

cd /tmp/mariadb

name=mariadb-$VER-ubuntu-$(echo $(lsb_release -rs | cut -d '.' -f 1,2 | tr '\n' '.' | sed 's/\.$//')).tgz

wget -c https://github.com/i18n-ops/ops/releases/download/mariadb-$VER/$name

groupadd mysql || true
useradd -r -g mysql -M -N -s /bin/false mysql || true
rm -rf /usr/local/mysql
mkdir -p /usr/local/mysql
tar -xvzf $name -C /usr/local/mysql --strip-components=1
chown -R mysql:mysql /usr/local/mysql
rm -rf /tmp/mariadb

cd $DIR
cp -f mariadb.service /etc/systemd/system/
systemctl daemon-reload
rsync -av $DIR/os/ /
rm -rf /etc/mysql/conf.d/rocksdb.cnf
touch /etc/mysql/init.sql
chown -R mysql:mysql /etc/mysql
SERVER_ID=$(hostname | sed 's/^u//')
sed -i "s/SERVER_ID/$SERVER_ID/g" /etc/mysql/mariadb.conf.d/50-server.cnf
direnv exec . $DIR/conf_port.sh

echo -e "[mysqld]\nreport_host=$(hostname)" >/etc/mysql/conf.d/host.cnf
grep -q '^mysql' /etc/security/limits.conf || echo -e "\nmysql soft nofile 108224\nmysql hard nofile 108224" >>/etc/security/limits.conf
