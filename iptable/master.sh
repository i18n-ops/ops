#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

# 把当前机器提升为主库
. /etc/ops/mariadb/conf.sh
. /etc/ops/mariadb/mariadb.sh

../mariadb/master.sh
