#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./ubuntu.sh ubuntu/optional/zh_CN.yml
./ubuntu.sh
