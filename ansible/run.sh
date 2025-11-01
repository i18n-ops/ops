#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "USAGE : $0 dir_or_yml"
  exit 1
fi

cout() {
  echo -e "\033[32m$1\033[0m"
}

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

./sh/setup.sh

VPS=../conf/ansible/vps.ini

run() {
  NAME=$(basename $1)
  cout "\n$NAME\n"
  ansible-playbook \
    -i $VPS \
    $@
}

set -ex

confdir=$1

if [ -d "$confdir" ]; then
  shift
  FILES=$(ls $confdir/*.yml | sort -n)
  for FILE in $FILES; do
    run $FILE $@
  done
else
  run $@
fi
