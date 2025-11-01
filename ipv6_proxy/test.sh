#!/usr/bin/env bash

set -e
cd /etc/ops/ipv6_proxy
. conf.sh
. ip_li.sh
set -x

f() {
  curl -x http://$IPV6_PROXY_USER:$IPV6_PROXY_PASSWD@$1:$IPV6_PROXY_PORT https://ifconfig.me
  echo 0
}

IFS=' ' read -ra ADDR <<<"$IPV6_PROXY_IP_LI"

for IP in "${ADDR[@]}"; do
  echo "> $IP"
  f $IP
  f $IP
  f $IP
done
