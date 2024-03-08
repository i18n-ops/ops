#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 hostname"
  exit 1
fi
direnv allow
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

ip=$(ssh -G $1 | awk '/^hostname / { print $2 }')

keyscan() {
  ssh-keygen -R $ip
  ssh-keyscan -H $ip >>~/.ssh/known_hosts
}

cd os

keyscan

chmod 700 _/root/.ssh
chmod 600 _/root/.ssh/*

rsync --perms --chown=root -avz _/ $1:/

if [ -d "host/$1" ]; then
  rsync --chown=root -avz host/$1/ $1:/
fi

cd $DIR

keyscan
ssh $1 "hostnamectl set-hostname $1 && passwd -d root"

if [ -z "$2" ]; then
  exit 0
fi

rsync --chown=root -avz zone/$2/ $1:/
