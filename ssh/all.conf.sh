#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./all.sh "cd ~/i18n/conf && git fetch --all && git reset --hard origin/main"
