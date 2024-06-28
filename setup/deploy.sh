#!/usr/bin/env bash

set -e

if [ -z "$2" ]; then
  echo "USAGE : $0 NAME:VER CONFIG_DIR"
  exit 1
else
  NAME=$(echo $1 | cut -d ':' -f1)
  VER=$(echo $1 | cut -d ':' -f2)
  CONF=$2
  . $CONF/API_SRV.sh
  key=$CONF/ssh/id_ed25519
  chmod 600 $key
fi

REPO=$(git config --get remote.origin.url | awk -F '[:/]' -v OFS='/' '{print $(NF-1), $NF}')

REPO=${REPO%.git}

URL=https://raw.githubusercontent.com/i18n-ops/ops/main/setup/curl.sh

ssh="ssh -q -o StrictHostKeyChecking=no -F $CONF/ssh/config -i $key"

for srv in $API_SRV; do
  echo $srv
  set +x # 避免密码暴露在github action的日志
  $ssh root@$srv "curl -sSf $URL|TZT_PASSWORD=$TZT_PASSWORD bash -s -- $REPO $VER $NAME"
  set -x
done
