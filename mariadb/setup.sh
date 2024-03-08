#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
cp -f mariadb.service /etc/systemd/system/

# ./compile.sh
# apt-get update -y
# apt-get install -y mariadb-server mariadb-plugin-rocksdb
rsync -av $DIR/os/ /
rm /etc/mysql/conf.d/rocksdb.cnf
SERVER_ID=$(hostname | sed 's/^u//')
sed -i "s/SERVER_ID/$SERVER_ID/g" /etc/mysql/mariadb.conf.d/50-server.cnf

ensure() {
  for i in "$@"; do
    mkdir -p $i
    chown -R mysql:mysql $i
  done
}

grep -q '^mysql' /etc/security/limits.conf || echo -e "\nmysql soft nofile 108224\nmysql hard nofile 108224" >>/etc/security/limits.conf

DATA_DIR=/mnt/data/i18n/mariadb
mkdir -p $DATA_DIR/binlog
ensure /var/log/mariadb $DATA_DIR

/usr/local/mysql/scripts/mysql_install_db --user=mysql --disable-log-bin --default-storage-engine=Aria --defaults-file=/etc/mysql/mariadb.cnf --basedir=/usr/local/mysql --plugin-dir=/usr/local/mysql/lib/plugin
rsync -av os/etc/mysql/conf.d/rocksdb.cnf /etc/mysql/conf.d/
systemctl enable --now mariadb || true
systemctl restart mariadb
# cd $DIR
