#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

if [ -z "$2" ]; then
  echo "Usage: $0 ./os/host_li.sh cmd" && exit 1
  exit 1
fi

set -ex

# brew install pdsh
source $1
rm -rf pdsh.log
shift
pdsh -w "$HOST_LI" -R ssh "bash -c 'set -ex && $@'" | tee pdsh.log
