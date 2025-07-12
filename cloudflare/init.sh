#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -ex
set -o allexport
. $DIR/env.sh
set +o allexport
../.mise/bin/coffee ./main.coffee
