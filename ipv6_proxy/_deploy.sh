#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

GIT=$(git config --get remote.origin.url)

./init.conf.sh

cd ~/i18n

source conf/env/ipv6_proxy.sh

pdsh -w "$IPV6_PROXY" "set -ex && . /etc/profile && mkdir -p ~/i18n && cd ~/i18n && [ -d ops ] && git -C ops pull || git clone -b dev $GIT ops && ./ops/ipv6_proxy/setup.sh"
