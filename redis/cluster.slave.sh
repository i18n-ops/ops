#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

source ../conf/redis.sh

host_ip() {
  getent hosts $1 | awk '{ print $1 }'
}

entry=$(host_ip u2):2000

add() {
  redis-cli -a $PASSWD --cluster add-node $(host_ip $1):2001 $entry \
    --cluster-slave --cluster-master-id $2
}

add u1 9946e279913ff7168eeb5f1b279e943f00f16745
add u2 129e169d911feb67e633254cef0e1c1f74523b5a
add u3 0d8e965b9f32dd860a81417d69474e175c5b5a57
