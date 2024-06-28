#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

gme $@
git push github main -f
cd ../ssh
./pssh.sh os/ALL.sh "cd ~/i18n/ops/nginx && git fetch --all && git checkout main && git reset --hard origin/main && ./init.conf.sh"
