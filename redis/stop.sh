#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

source ../conf/redis.sh

for i in ${PORT_LI[@]}; do
  systemctl stop redis-$PROJECT-$i
done
