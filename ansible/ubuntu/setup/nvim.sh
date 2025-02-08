#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

urls=(
  "https://fastly.jsdelivr.net/gh/junegunn/vim-plug/plug.vim"
  "${GITHUB_PROXY}https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  "https://cdn.jsdelivr.net/gh/junegunn/vim-plug/plug.vim"
)

plug_vim="/etc/vim/plug.vim"

if [ ! -e "$plug_vim" ] || [ ! -s "$plug_vim" ]; then
  mkdir -p /etc/vim
  for url in "${urls[@]}"; do
    wget "$url" -O $plug_vim && break || true
  done
fi

if [ ! -f "$plug_vim" ]; then
  echo "FAILED TO DOWNLOAD vim-plug"
  exit 1
fi

vi -E -u /etc/vim/sysinit.vim +PlugInstall +qa

vi -u /etc/vim/sysinit.vim +UpdateRemotePlugins +qa

vi +'CocInstall -sync coc-biome coc-rust-analyzer coc-json coc-yaml coc-css coc-python coc-vetur coc-svelte' +qa

if [ "$(uname -m)" != "aarch64" ]; then
  vi +'CocInstall -sync coc-tabnine' +qa
fi
