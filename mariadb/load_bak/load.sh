#!/usr/bin/env bash

# DIR=$(realpath $0) && DIR=${DIR%/*}
# cd $DIR
set -ex

if [ -z "$1" ]; then
  echo "USAGE : $0 backup_dir"
  exit 1
fi

DATADIR=/mnt/data/mariadb/data

if [ -d "$DATADIR" ]; then
  echo -e "\n$DATADIR EXISTS !\n\nIf you want to rebuild it, please run:\n\nrm -rf $DATADIR\n"
  exit 1
fi

systemctl stop mariadb

mkdir -p $DATADIR

/usr/bin/python3 /usr/local/mariadb/bin/myrocks_hotbackup --move_back \
  --datadir=$DATADIR \
  --rocksdb_datadir=$DATADIR/\#rocksdb \
  --rocksdb_waldir=$DATADIR \
  --backup_dir=$1

chown -R mariadb:mariadb $DATADIR

systemctl start mariadb
