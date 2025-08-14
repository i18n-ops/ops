#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./all.conf.sh
./c.sh "systemctl restart api"
