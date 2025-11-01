#!/usr/bin/env bash

mkdir -p /root/i18n
cd /root/i18n
if [ -d "conf" ]; then
  cd conf
  git fetch --all && git reset --hard origin/dev
else
  git clone -b dev --depth=1 git@atomgit.com:i18n-api/conf.git
fi
