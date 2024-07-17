#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if [ -z "$1" ]; then
  echo "USAGE : $0 name"
  exit 1
else
  export name=$1
fi

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

cp ./$name.service /etc/systemd/system/

systemctl daemon-reload

systemctl enable --now $name
systemctl restart $name

systemctl status $name --no-pager

journalctl -u $name -n 10 --no-pager --no-hostname
