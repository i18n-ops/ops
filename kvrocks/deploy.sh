#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

source ../conf/kvrocks.sh

nohup pdsh -w "$HOST_LI" 'set -ex && mkdir -p i18n && cd i18n && rm -rf conf && git clone --depth=1 -b main git@atomgit.com:i18n-api/conf.git && cd ~/i18n/ops && git fetch --all && git reset --hard origin/dev && direnv allow && ./env.sh && cd kvrocks && direnv allow && direnv exec . ./setup.sh && direnv exec . ./sentinel.sh' &
