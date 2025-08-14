#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. ./os/ALL.sh

for HOST in $HOST_LI; do
  echo $HOST
  rsync --delete -avzP ../nginx $HOST:/opt/ops/
  rsync --delete -avzP ../conf/nginx $HOST:/etc/ops/
done

./all.sh "rm -rf /etc/nginx && ln -s /opt/ops/nginx/conf /etc/nginx && /opt/ops/nginx/init.sh"
