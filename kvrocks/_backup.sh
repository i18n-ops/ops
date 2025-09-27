#!/usr/bin/env bash

. /etc/ops/kvrocks/conf.sh

set -ex

rcli="redis-cli -a $R_PASSWORD -h 127.0.0.1 -p $R_PORT"
now=$(date +%s)

$rcli BGSAVE

while true; do
  lastsave=$($rcli LASTSAVE)
  if [ "$lastsave" -ge "$now" ]; then
    break
  fi
  sleep 1
done
