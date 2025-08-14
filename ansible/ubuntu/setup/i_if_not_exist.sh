#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
for i in "$@"; do
  if ! command -v $i &>/dev/null; then
    sh="./$i.sh"
    echo $sh
    $sh
  fi
done
