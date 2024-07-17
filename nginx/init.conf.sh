#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
rm -rf /etc/nginx
ln -s $DIR/conf /etc/nginx

cd conf

sed -e "s/VPS/$(hostname)/g" nginx.tmpl.conf >nginx.conf
sed -i "s/worker_processes [0-9]\+;/worker_processes $(nproc);/" nginx.conf

mkdir -p /cache/nginx/proxy_temp

chown -R www-data:www-data /cache/nginx

nginx -t

systemctl start nginx
systemctl reload nginx
