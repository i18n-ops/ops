#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

urls=(
  "${GITHUB_PROXY}https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  "https://fastly.jsdelivr.net/gh/junegunn/vim-plug/plug.vim"
  "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  "https://cdn.jsdelivr.net/gh/junegunn/vim-plug/plug.vim"
)

plug_vim="/etc/vim/plug.vim"
mkdir -p /etc/vim

for url in "${urls[@]}"; do
  curl --max-time 16 --retry 99 -fLo "$plug_vim" "$url" && break
done

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
