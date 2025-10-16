#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

ensure() {
  for i in "$@"; do
    mise use -y -g $i@latest --pin
  done
}
ensure nodejs golang python neovim

update-alternatives --install /usr/bin/vi vi /opt/mise/shims/nvim 60
update-alternatives --set vi /opt/mise/shims/nvim
update-alternatives --install /usr/bin/vim vim /opt/mise/shims/nvim 60
update-alternatives --set vim /opt/mise/shims/nvim

mise prune -y
mise exec -- pip install -U parso jedi python-language-server
