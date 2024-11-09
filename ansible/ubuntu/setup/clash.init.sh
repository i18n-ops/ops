#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

. env.sh

set -ex

[[ ! -f /etc/clash/conf.sh ]] && exit
cd /etc/clash

fp=conf.yml

[[ ! -f $fp || $(find $fp -mtime +5) ]] &&
  . conf.sh &&
  wget $CLASH_CONF_URL -O $fp

gitdown() {
  fp=$2
  [[ ! -f $fp || $(find $fp -mtime +30) ]] &&
    rm -rf $fp.* &&
    ver=$($CURL -SsL https://api.github.com/repos/$1/releases/latest | jq -r '.tag_name') &&
    wget -c ${GITHUB_PROXY}https://github.com/$1/releases/download/$ver/$fp -O $fp.$ver &&
    mv $fp.$ver $fp
}

gitdown Loyalsoldier/geoip Country.mmdb &
gitdown Loyalsoldier/v2ray-rules-dat geosite.dat &

wait
