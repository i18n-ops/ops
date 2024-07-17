#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

OB_CLUSTER=ob
CTRL_VPS=c0

cd /opt/$OB_CLUSTER

LI=(oceanbase)
# LI=(obagent obproxy oceanbase ocpexpress)

for i in ${LI[@]}; do
  if [ -d "$i/run" ]; then
    rm -rf $i/run/*.pid
  fi
done

exec timeout 1h ssh $CTRL_VPS "bash -c '. /root/.oceanbase-all-in-one/bin/env.sh && exec obd cluster start $OB_CLUSTER'"
