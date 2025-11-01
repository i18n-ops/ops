#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

dump_ip() {
  js="../conf/dns/$1.js"
  rm -f $js

  echo "export default [" >>"$js"
  shift
  for host in $@; do
    ip_info=$(ssh -q "$host" "curl -sS 6.ipw.cn && echo -n ' ' && curl -sS 4.ipw.cn")

    ipv6=$(echo "$ip_info" | awk '{print $1}')
    ipv4=$(echo "$ip_info" | awk '{print $2}')

    echo "  ['$host', '$ipv4', '$ipv6']," >>"$js"
  done

  echo "]" >>"$js"
}

dump_ip cn a0 a1
dump_ip us us1 us2 us3
