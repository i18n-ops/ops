#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

source ~/i18n/conf/env/ipv6_proxy.sh

set -e

f() {
  curl -x http://$IPV6_PROXY_USER:$IPV6_PROXY_PASSWD@$1:$IPV6_PROXY_PORT https://ifconfig.me
  echo 0
}

IFS=' ' read -ra ADDR <<<"$IPV6_PROXY"

for IP in "${ADDR[@]}"; do
  echo "> $IP"
  f $IP
  f $IP
  f $IP
done
