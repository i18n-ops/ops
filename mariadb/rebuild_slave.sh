#!/usr/bin/env bash

# 先 pip install mariadb
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

if [ -z "$1" ]; then
  echo "USAGE : $0 MASTER_IP"
  exit 1
else
  MASTER_IP=$1
fi

set -ex

if ! command -v socat &>/dev/null; then
  apt-get install -y python3-mysqldb socat
fi

./backup_master.sh $MASTER_IP
./load_backup.sh /tmp/bak/mariadb.master
sleep 6
./init.master.sh
