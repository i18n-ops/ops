#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

source ../conf/redis.sh

sed -i '/vm.overcommit_memory/d' /etc/sysctl.conf
echo "vm.overcommit_memory = 1" >>/etc/sysctl.conf

sysctl -p

useradd -r -s /sbin/nologin redis || true
# mkdir -p /run/redis
# useradd -g www-data redis || true
# chown redis:www-data /run/redis

ensure_dir() {
  mkdir -p $1
  chown -R redis:redis $1
}
ensure_dir /var/log/redis-$PROJECT

sedvar() {
  sed -i "s/PORT/$PORT/g" $1
  sed -i "s/PROJECT/$PROJECT/g" $1
  sed -i "s/PASSWD/$PASSWD/g" $1
}

add() {

  ensure_dir /mnt/data/$PROJECT/redis/$PORT

  mkdir -p /etc/redis

  etc_conf=/etc/redis/redis-$PROJECT-$PORT.conf
  cp ./redis.conf $etc_conf
  sedvar $etc_conf

  name=redis-$PROJECT-$PORT

  system_service=/etc/systemd/system/$name.service
  cp ./redis.service $system_service

  sedvar $system_service

  systemctl daemon-reload

  systemctl enable --now $name
  systemctl restart $name

  systemctl status $name --no-pager

  journalctl -u $name -n 10 --no-pager --no-hostname
}

for i in ${PORT_LI[@]}; do
  export PORT=$i
  add
done
