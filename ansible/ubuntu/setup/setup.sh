#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

./rust.sh

if [ ! -f "/usr/local/bin/rg" ]; then
  ./rg.sh
fi

if [ -f "/opt/atuin/env" ]; then
  . /opt/atuin/env
fi

./proxy_then_setup.sh
./nvim.sh
