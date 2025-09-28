#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

if [ -d "/etc/nginx" ]; then
  rm -rf /tmp/nginx.bak
  mv /etc/nginx /tmp/nginx.bak
fi

cp -R $DIR/conf /etc/nginx

VPS=$(hostname)
ZONE=$(hostname | grep -o '^[^0-9]*')

cd /etc/nginx

mkdir -p /etc/nginx/zone
touch /etc/nginx/zone/$ZONE.conf
mkdir -p /etc/nginx/vps/$VPS

sed -e "s/VPS/$VPS/g" nginx.tmpl.conf >nginx.conf
rm nginx.tmpl.conf
sed -i "s/ZONE/$ZONE/g" nginx.conf
sed -i "s/worker_processes [0-9]\+;/worker_processes $(nproc);/" nginx.conf

mkdir -p /cache/nginx/proxy_temp
chown -R www-data:www-data /cache/nginx

if command -v nginx &>/dev/null; then
cp $DIR/setup/nginx.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable nginx --now
systemctl reload nginx
systemctl status nginx --no-pager
fi
