#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

direnv allow

./ipv6.sh

cd ../ssl
direnv exec . ./init.sh # 必须这样, 不然貌似 .envrc 不执行

if ! command -v nginx &>/dev/null; then
  cd ../ubuntu
  ./nginx.sh
fi

cd ../nginx
./init.sh

cd ../chasquid
direnv allow
direnv exec . ./init.sh

cd ../orchestrator
./setup.sh

if ! command -v redis-sentinel &>/dev/null; then
  cd ../redis
  ./make.sh
fi

cd ../kvrocks
direnv allow
if ! command -v kvrocks &>/dev/null; then
  direnv exec . ./setup.sh
fi
direnv exec . ./sentinel.sh

cd ../mariadb
direnv allow
direnv exec . ./setup.sh
./initdb.sh

cd ../iptable
./service.sh
