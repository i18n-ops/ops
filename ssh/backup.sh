#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. os/ALL.sh

for i in $HOST_LI; do
  rsync --mkpath -avz --progress $i:/etc/ssh/ssh_host_* ./os/vps/$i/etc/ssh &
  rsync --mkpath -avz --progress $i:/root/.ssh/known_hosts ./os/vps/$i/root/.ssh/ &
done
wait
