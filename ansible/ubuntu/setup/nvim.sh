#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

rm -rf /etc/vim
cd /etc
git clone -b dev --depth=1 https://github.com/i18n-site/lazyvim.git vim
