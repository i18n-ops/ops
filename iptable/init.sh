#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

log=/var/log/iptable.init.log
rm -f $log

run() {
  ./$1.sh >>$log 2>&1 &
}

run mariadb
wait
