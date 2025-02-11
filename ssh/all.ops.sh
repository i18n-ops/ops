#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./all.sh "cd ~/i18n/ops/conf && git fetch --all && git reset --hard origin/dev && cd ~/i18n/ops && git fetch --all && git reset --hard origin/dev"
