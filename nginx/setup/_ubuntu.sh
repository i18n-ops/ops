#!/usr/bin/env bash

if ! command -v go &>/dev/null; then
  apt-get install -y golang
fi

apt install -y cmake ninja-build g++ libunwind-dev libpcre3-dev zlib1g-dev libxslt1-dev libgd-dev libgeoip-dev git wget patch make mercurial ninja-build jq curl unzip libssl-dev
