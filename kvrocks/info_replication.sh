#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

export REDISCLI_AUTH=$R_PASSWORD

set -ex

if ! command -v redis-cli &>/dev/null; then
  apt-get install -y redis-tools
fi

redis-cli -h $R_MASTER_IP -p $R_PORT -c info replication
