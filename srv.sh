#!/usr/bin/env bash

set -ex

mkdir -p ~/i18n
cd ~/i18n

clone() {
  org=$1
  shift
  for i in "$@"; do
    if [ -d "$i" ]; then
      cd $i
      git fetch --all && git reset --hard origin/dev
      cd ..
    else
      git clone -b dev git@atomgit.com:$org/$i.git
    fi
  done
}

clone i18n rust

clone i18n-api srv conf 'in'

mkdir -p srv/mod
cd srv/mod

clone i18n-api pub private
