#!/usr/bin/env bash

# 先 pip install mariadb

if [ -z "$1" ]; then
  echo "USAGE : $0 MASTER_IP"
  exit 1
else
  MASTER_IP=$1
fi

set -ex

SOCAT_PORT=4919

ssh $MASTER_IP "set -ex && (kill -9 \$(lsof -t -i:$SOCAT_PORT) || true) && BAKDIR=/tmp/myrocksBak && rm -rf \$BAKDIR && mkdir -p \$BAKDIR && /usr/bin/python3 /usr/local/mariadb/bin/myrocks_hotbackup --socket=/run/mariadb/mariadb --stream=tar --checkpoint_dir=\$BAKDIR | zstd -c -5 | exec timeout 23h socat - TCP-LISTEN:$SOCAT_PORT,reuseaddr" &

TMP=/tmp/bak/mariadb.master

rm -rf $TMP

mkdir -p $TMP

sleep 9

timeout 23h socat -u TCP:$MASTER_IP:$SOCAT_PORT STDOUT | zstd -dc | tar -xi -C "$TMP"
