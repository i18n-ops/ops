#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

NAME=$1

shift 1

ip_li=()

for hostname in "$@"; do
  ip=$(ssh -G "$hostname" | grep 'hostname' | head -n 1 | awk '{print $2}')
  ip_li+=("$ip")
done

ip_li=$(
  IFS=' '
  echo "${ip_li[*]}"
)

cd ../../conf/$NAME

echo "export ${NAME^^}_IP_LI=\"$ip_li\"" >ip_li.sh

chmod +x ip_li.sh

# git add ip_li.sh || true
#
# if [[ -n $(git status -s) ]]; then
#   git commit -m "update ipv6_proxy ip_li.sh"
#   git pull || true
#   git push
# fi
