#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

name=oceanbase

to=/etc/systemd/system/$name.service
cp ./service $to
service_sh=$DIR/$name.sh

sed -i "s#EXEC#${service_sh}#" $to
sed -i "s#NAME#${name}#" $to

systemctl daemon-reload

systemctl enable --now $name
systemctl restart $name

systemctl status $name --no-pager

journalctl -u $name -n 10 --no-pager --no-hostname
