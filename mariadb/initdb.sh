#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

DATA_DIR=/mnt/data/i18n/mariadb
MYSQL_DIR=/usr/local/mysql

ensure() {
  for i in "$@"; do
    mkdir -p $i
    chown -R mysql:mysql $i
  done
}

mkdir -p $DATA_DIR/binlog
ensure /var/log/mariadb $DATA_DIR /run/mysqld
rm -rf /etc/mysql/conf.d/rocksdb.cnf

/usr/local/mysql/scripts/mysql_install_db --user=mysql --disable-log-bin --default-storage-engine=Aria \
  --defaults-file=/etc/mysql/mariadb.cnf --basedir=$MYSQL_DIR --plugin-dir=$MYSQL_DIR/lib/plugin
cp os/etc/mysql/conf.d/rocksdb.cnf /etc/mysql/conf.d/
systemctl daemon-reload
systemctl enable --now mariadb || true
systemctl restart mariadb
