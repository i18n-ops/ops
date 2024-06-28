#!/usr/bin/env bash

set -ex

mkdir -p ~/i18n
cd ~/i18n
if [ ! -d "conf" ]; then
  git clone --depth=1 git@atomgit.com:i18n-api/conf.git
fi
