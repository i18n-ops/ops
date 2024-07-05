#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

source ../conf/nginx.sh

nohup pdsh -w "$HOST_LI" 'cd ~/i18n/ops/ssl && ./init.sh ' &
