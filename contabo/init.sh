#!/usr/bin/env bash

set -ex

cd ~

# 升级 ubuntu
bash <(curl -s https://raw.githubusercontent.com/i18n-ops/ubuntu/main/upgrade.sh)

grep -q '^\[include\]' ~/.gitconfig || rm -f ~/.gitconfig
# 安装常用软件
CN=1 bash <(curl -s https://raw.githubusercontent.com/i18n-ops/ubuntu/main/boot.sh)

. /etc/profile
/os/init.sh
~/ubuntu/snapper/init.sh

mkdir -p ~/i18n
cd ~/i18n

export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519.i18n'

clone() {
  if [ -z "$2" ]; then
    local name=$(basename ${1%.git})
  else
    local name=$2
  fi

  if [ -d "$name" ]; then
    cd $name
    git fetch --all && git reset --hard origin/main || true
    cd ..
  else
    git clone --depth=1 $1 $name
  fi
}

clone git@github.com:i18n-api/conf-ol.git conf
clone git@github.com:i18n-ops/ops.git

cd ops/contabo
direnv allow
direnv exec . ./srv.sh
