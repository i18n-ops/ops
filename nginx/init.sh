#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

mkdir -p /var/log/nginx
chown -R www-data:www-data /var/log/nginx
touch /var/run/nginx.pid
chown www-data:www-data /var/run/nginx.pid

rm -rf /etc/nginx
ln -s $DIR/conf /etc/nginx
nginx -t
systemctl enable nginx --now
systemctl restart nginx
systemctl status nginx --no-pager

journalctl -u nginx -n 10 --no-pager --no-hostname
