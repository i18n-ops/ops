#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -ex

cpso() {
  mkdir -p /so
  ldd $1 | grep "=> /" | awk '{print $3}' | xargs -I '{}' sh -c 'cp -L "{}" /so/'
}

cpso /usr/sbin/_nginx

rm -rf /so/libc.so.* /so/libm.so.* /so/libz.so.*
