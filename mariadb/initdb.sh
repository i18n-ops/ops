#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

DATA_DIR=/mnt/data/mariadb

if [ -d "$DATA_DIR" ]; then
  exit
fi

MYSQL_DIR=/usr/local/mariadb

ensure() {
  for i in "$@"; do
    mkdir -p $i
    chown -R mariadb:mariadb $i
  done
}

mkdir -p $DATA_DIR/binlog
ensure /var/log/mariadb $DATA_DIR /run/mariadb

/usr/local/mariadb/scripts/mariadb-install-db \
  --user=mariadb --disable-log-bin --default-storage-engine=Aria \
  --defaults-file=/etc/mariadb/mariadb.cnf \
  --basedir=$MYSQL_DIR --plugin-dir=$MYSQL_DIR/lib/plugin

systemctl daemon-reload
systemctl enable --now mariadb || true
systemctl restart mariadb
