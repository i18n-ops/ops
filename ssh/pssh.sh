#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

[ ! -f "$1" ] && echo "Usage: $0 ./os/xxx.sh # HOST_LI" && exit 1

set -ex

# brew install pdsh
source $1
rm -rf pdsh.log
shift
pdsh -w "$HOST_LI" -R ssh "bash -c '$@'" | tee pdsh.log
