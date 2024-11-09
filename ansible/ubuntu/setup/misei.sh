#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

misei() {
  mise install $1@latest
  last=$(mise ls --json $1 | jq -r 'last(.[] | .version)')
  mise global $1@$last
  mise list $1 | tail -n +1 | head -n -1 | awk '{print $2}' | xargs -I {} mise remove $1@{}
}

ensure() {
  for i in "$@"; do
    misei $i
  done
}

ensure nodejs golang python
