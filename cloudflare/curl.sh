#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "Usage: $0 <host> <url> <url> ..."
  exit 1
fi

host=$1
shift
echo $LANG | grep -q zh_ && lang=zh-CN || lang=en

CURL="curl -sSf"

IP=$($CURL -H "accept:application/dns-json" "https://cloudflare-dns.com/dns-query?name=$host&type=A" | jq -r '.Answer[0].data')

echo -e "$host $IP\n"

for i in "$@"; do
  cmd="curl -i --resolve "$host:443:$IP" https://$host$i"
  echo -e "❯ $cmd"
  $cmd
  echo ''
done

cmd="$CURL http://ip-api.com/json/$IP?lang=$lang"

echo $cmd
$cmd | jq
