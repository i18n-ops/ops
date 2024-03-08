#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

source ../conf/oceanbase.sh

cd /opt/oceanbase/$OB_CLUSTER

LI=(obagent obproxy oceanbase ocpexpress)

for i in ${LI[@]}; do
  if [ -d "$i/run" ]; then
    rm -rf $i/run/*.pid
  fi
done

cmd="/root/.oceanbase-all-in-one/obd/usr/bin/obd cluster start $OB_CLUSTER"
exec ssh u2 "bash -c '$cmd'"
