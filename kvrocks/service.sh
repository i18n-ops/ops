#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

cp ./kvrocks.service /etc/systemd/system/

systemctl daemon-reload

systemctl enable --now kvrocks
systemctl restart kvrocks

systemctl status kvrocks --no-pager

journalctl -u kvrocks -n 10 --no-pager --no-hostname
