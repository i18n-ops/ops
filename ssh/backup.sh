#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

cd os
source ALL.sh

backup() {
  mkdir -p host/$1/etc/
  rsync -avz --progress $1:/etc/sudoers host/$1/etc/
  rsync -avz --progress $1:/etc/hosts host/$1/etc/
}

for host in $ALL; do
  backup $host &
done

wait

git pull
git add .
git commit -m.
git push
