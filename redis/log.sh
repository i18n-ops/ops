#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
source ../conf/redis.sh

set -ex

if [ -v 1 ]; then
  journalctl -f --no-pager --no-hostname -u redis-$PROJECT-$1
else
  for i in ${PORT_LI[@]}; do
    journalctl -n 10 --no-pager --no-hostname -u redis-$PROJECT-$i
    tail -10 /var/log/redis-$PROJECT/$i.log
  done
fi
