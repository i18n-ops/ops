#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

add-apt-repository ppa:neovim-ppa/unstable -y
apt-get update
apt-get install neovim -y
