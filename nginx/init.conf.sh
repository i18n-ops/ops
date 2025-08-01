#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

if [ -d "/etc/openresty" ]; then
  rm -rf /tmp/openresty.bak
  mv /etc/openresty /tmp/openresty.bak
fi

cp -R $DIR/conf /etc/openresty

VPS=$(hostname)
ZONE=$(hostname | grep -o '^[^0-9]*')

cd /etc/openresty

mkdir -p /etc/openresty/ZONE
touch /etc/openresty/zone/$ZONE.conf
mkdir -p /etc/openresty/vps/$VPS

sed -e "s/VPS/$VPS/g" nginx.tmpl.conf >nginx.conf
rm nginx.tmpl.conf
sed -i "s/ZONE/$ZONE/g" nginx.conf
sed -i "s/worker_processes [0-9]\+;/worker_processes $(nproc);/" nginx.conf

mkdir -p /cache/openresty/proxy_temp
chown -R www-data:www-data /cache/openresty

systemctl daemon-reload
systemctl enable openresty --now
openresty -s reload
systemctl status openresty --no-pager
