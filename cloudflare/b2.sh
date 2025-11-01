#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -a
. ./env.sh
set +a
set -ex
mise exec -- ./b2.coffee $@
