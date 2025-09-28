#!/usr/bin/env bash

cd /tmp
rm -rf czmod
if ! command -v czmod &>/dev/null; then
  git clone --depth=1 https://github.com/skywind3000/czmod.git
  cd czmod
  ./build.sh && mv czmod /usr/local/bin
  rm -rf czmod
fi
