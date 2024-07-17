#!/usr/bin/env bash

set -e
DIR=$(dirname "${BASH_SOURCE[0]}")
if echo ":$PATH:" | grep -q ":$DIR/.mise/bin:"; then
  exit 0
fi

cd $DIR
set -e

set -o allexport
if [ -z "$EXE_RG" ]; then
  EXE_RG=$(which rg)
fi

if [ -z "$EXE_FD" ]; then
  EXE_FD=$(which fd)
fi
set +o allexport

PATH=$DIR/.mise/bin:$PATH
.mise/bin/bun_i .

clone() {
  if [ ! -d "$1" ]; then
    GIT=$(dirname $(git remote -v | head -1 | awk '{print $2}'))
    git clone -b dev --depth=1 $GIT/$1.git
  fi
}

clone conf
clone ubuntu
#source ./conf/env.sh
