#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

source ../conf/redis.sh

host_ip() {
  getent hosts $1 | awk '{ print $1 }'
}

port=2000
redis-cli -a $PASSWD --cluster-replicas 0 --cluster create \
  $(host_ip u1):$port \
  $(host_ip u2):$port \
  $(host_ip u3):$port
