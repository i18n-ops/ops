#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

# apt-get install -y python3-mysqldb
# wget https://raw.githubusercontent.com/MariaDB/server/6fff22422ed26e02d47e9447a292da9fc45c9679/storage/rocksdb/myrocks_hotbackup.py -O /usr/local/mariadb/bin/myrocks_hotbackup
# chmod +x /usr/local/mariadb/bin/myrocks_hotbackup

CKDIR=/tmp/myrocks.checkpoint
BKDIR=/tmp/bak/i18n/mariadb

rmdir() {
  rm -rf $CKDIR $BKDIR
}

rmdir

mkdir -p $CKDIR $BKDIR

/usr/bin/python3 /usr/local/mariadb/bin/myrocks_hotbackup --socket=/run/mariadb/mariadb --stream=tar --checkpoint_dir=$CKDIR | tar -xi -C $BKDIR
