#!/usr/bin/env bash

set -ex

vi -E -u /etc/vim/sysinit.vim +PlugInstall +qa

vi -u /etc/vim/sysinit.vim +UpdateRemotePlugins +qa

vi +'CocInstall -sync coc-biome coc-rust-analyzer coc-json coc-yaml coc-css coc-python coc-vetur coc-svelte' +qa

if [ "$(uname -m)" != "aarch64" ]; then
  vi +'CocInstall -sync coc-tabnine' +qa
fi
