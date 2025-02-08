#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

if [ -z "$1" ]; then
  echo "USAGE : $0 mail.xxx.xxx"
  exit 1
else
  domain=$1
fi

set -ex

HOST_LI=$(./deploy.js $domain)

nohup pdsh -w "$HOST_LI" '\
. /etc/profile &&\
set -ex &&\
cd ~/i18n/ops && direnv allow &&\
git fetch --all && git reset --hard origin/dev &&\
direnv exec . ./env.sh &&\
cd conf && git fetch --all && git reset --hard origin/dev && cd .. &&\
cd chasquid && git fetch --all && git reset --hard origin/dev &&\
direnv allow && direnv exec . ./init.sh ' &
