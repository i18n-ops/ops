#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./rust.sh

ensure() {
  for i in "$@"; do
    if ! command -v $i &>/dev/null; then
      ./$i.sh
    fi
  done
}

ensure rg atuin
# ./clash_rs.sh
#
# ./nvim.sh

./mise.sh
./misei.sh
