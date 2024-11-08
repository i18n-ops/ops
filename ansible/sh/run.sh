#!/usr/bin/env bash

cout() {
  echo -e "\033[32m$1\033[0m"
}

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR

./sh/setup.sh

VPS=../conf/ansible/vps

LOGDIR=/tmp/ansible/$OS
mkdir -p $LOGDIR

set -ex

run() {
  NAME=$(basename $1)
  cout "\n$NAME\n"
  ANSIBLE_LOG_PATH=$LOGDIR/$NAME.log \
    ansible-playbook \
    -i $VPS \
    $1
}

if [ $# -eq 0 ]; then
  FILES=$(ls $DIR/$OS/*.yml | sort -V)
  for FILE in $FILES; do
    run $FILE
  done
else
  run $1
fi
