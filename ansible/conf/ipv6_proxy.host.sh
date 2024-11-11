#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

ip_li=()

for hostname in "$@"; do
  ip=$(ssh -G "$hostname" | grep 'hostname' | head -n 1 | awk '{print $2}')
  ip_li+=("$ip")
done

ip_li=$(
  IFS=' '
  echo "${ip_li[*]}"
)

echo "IPV6_PROXY=\"$ip_li\"" >../../conf/ipv6_proxy/host.sh

cd ../../conf

git add -u || true

if [[ -n $(git status -s) ]]; then
  git commit -m "update ipv6_proxy host.sh"
  git pull || true
  git push
fi
