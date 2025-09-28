#!/usr/bin/env bash

set -ex

export PDSH_SSH_ARGS_APPEND="-q -o StrictHostKeyChecking=no"

if [ ! -d "~/.ssh" ]; then
  mkdir -p ~/.ssh
  cp dist/ssh/id_ed25519 ~/.ssh/
  cp /etc/ops/ansible/ssh_config ~/.ssh/config
  chown 700 ~/.ssh
  chmod 600 ~/.ssh/*
fi

if ! command -v pdsh &>/dev/null; then
  apt-get install -y pdsh
fi

. dist/srv_li.sh

RUN=$1

shift

pdsh -w "$SRV_LI" -l root -R ssh "/opt/ops/srv/$RUN.sh $@"
