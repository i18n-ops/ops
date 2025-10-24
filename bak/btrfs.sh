#!/usr/bin/env bash

set -ex

NAME=i18n

KEEP=90

SRC=/mnt/data/$NAME
BAK=/mnt/snapshot/$NAME

mkdir -p $BAK

TO=$BAK/$(date +%Y-%m-%d)

[ -d $TO ] || btrfs subvolume snapshot -r $SRC $TO

find $BAK -mindepth 1 -maxdepth 1 -type d | sort | head -n -$KEEP | xargs -I{} btrfs subvolume delete {}

# 增量发送到远程
# btrfs send -p $D1 $SRC | btrfs receive $TODAY
