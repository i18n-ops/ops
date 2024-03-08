#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}

cd $DIR

set -ex

rustup update

cd conf

git pull

cp -f ./ipv6_proxy.env.sh /etc

URL=https://atomgit.com/i18n-in/ipv6_proxy/raw/dev/service.curl.sh

curl -sSf $URL | bash
