#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

rm -rf /tmp/nginx.bak
mv /etc/nginx /tmp/nginx.bak
ln -s $DIR/conf /etc/nginx

cd conf

curl -s -o /dev/null -I --connect-timeout 2 -m 4 -s https://x.com && ZONE=global || ZONE=cn

sed -e "s/VPS/$(hostname)/g" nginx.tmpl.conf >nginx.conf
sed -i "s/ZONE/$ZONE/g" nginx.conf
sed -i "s/worker_processes [0-9]\+;/worker_processes $(nproc);/" nginx.conf

mkdir -p /cache/nginx/proxy_temp

chown -R www-data:www-data /cache/nginx

for i in "$@"; do
  if ! command -v nginx &>/dev/null; then
    nginx -t
    systemctl restart nginx
  fi
done
