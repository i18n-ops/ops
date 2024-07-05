#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./all.sh "cd ~/i18n/ops/nginx && git fetch --all && git reset --hard origin/dev && rm -rf /var/log/nginx && ./init.sh"
