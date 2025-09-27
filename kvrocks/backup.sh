#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

. /etc/ops/kvrocks/conf.sh

set -ex

SELF_IP=$(ip addr show | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | while read -r ip; do [[ " $KVROCKS_IP_LI " == *" $ip "* ]] && echo $ip && break; done)

if [ -z "$SELF_IP" ]; then
  echo "SELF_IP NOT FOUND"
  exit 1
fi

MASTER_IP=$(redis-cli -a $R_PASSWORD -h $SELF_IP -p $R_PORT INFO | grep master_host | cut -d':' -f2 | tr -d '\r\n')

BACKUP=/mnt/data/i18n/kvrocks/backup
BKDIR=/tmp/bak/i18n/kvrocks

rm -rf $BKDIR

if [ -n "$MASTER_IP" ]; then
  mkdir -p $BKDIR
  ssh $MASTER_IP "rm -rf $BACKUP && $DIR/_backup.sh $BACKUP"
  rsync -avz --remove-source-files $MASTER_IP:$BACKUP/ $BKDIR/
else
  ./_backup.sh
  mv $BACKUP $BKDIR
fi
