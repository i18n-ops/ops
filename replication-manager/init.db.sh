#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. ../conf/replication-manager.sh
to=/tmp/replication-manager.init.sql
sed -e "s/MANAGER_PASSWORD/$MANAGER_PASSWORD/g" \
  -e "s/REPUSER_PASSWORD/$REPUSER_PASSWORD/g" \
  init.sql >$to
