#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

rm -rf /etc/snapper/configs/*
sed -i 's/^SNAPPER_CONFIGS=".*"/SNAPPER_CONFIGS=""/' /etc/default/snapper
./init.py
umount -a || true
mount -a
./rm.sh
cd /bak && fd -t d "snapshot" --max-depth=4 | xargs -I {} btrfs subvolume delete {}
rm -rf /bak/*
