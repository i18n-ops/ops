#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

scan() {
  for i in "$@"; do
    ssh-keyscan $i >>~/.ssh/known_hosts
  done
}

echo >~/.ssh/known_hosts

. ../ssh/os/ALL.sh

scan github.com atomgit.com $HOST_LI

sort ~/.ssh/known_hosts | uniq | grep -v "^#" | sponge ~/.ssh/known_hosts
