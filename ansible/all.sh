#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

for i in ubuntu optional; do
  OS=$i ./run.sh
done
