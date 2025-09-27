#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

if [ -n "$GFW" ]; then
  ./i_if_not_exist.sh clash-rs
  ./clash.init.sh
  export http_proxy=http://127.0.0.1:7890 \
    https_proxy=$http_proxy \
    HTTP_PROXY=$http_proxy \
    HTTPS_PROXY=$http_proxy
  ./msh.sh /usr/local/bin/clash ./proxyed_setup.sh
else
  ./proxyed_setup.sh
fi
