#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -ex

[ -d "/.snapshots" ] && exit

. /etc/profile

systemctl enable --now snapper-timeline.timer
systemctl enable --now snapper-cleanup.timer

umount -a || true

conf() {
  sed -i "s/$1=\"[[:digit:]]\+\"/$1=\"$2\"/" /etc/snapper/configs/$3
}

conf_file() {
  local name=${1//\//_}
  local dir=/${2:-$1}
  cd $dir
  rm -rf .snapshots
  snapper -c $name create-config $dir
  conf NUMBER_LIMIT 50 $name
  conf NUMBER_LIMIT_IMPORTANT 3 $name
  conf TIMELINE_LIMIT_HOURLY 16 $name
  conf TIMELINE_LIMIT_DAILY 8 $name
  conf TIMELINE_LIMIT_WEEKLY 4 $name
  conf TIMELINE_LIMIT_MONTHLY 2 $name
  conf TIMELINE_LIMIT_YEARLY 1 $name

  local bakdir=/bak/$1

  rm -rf .snapshots
  if [ ! -d "$bakdir" ]; then
    btrfs subvolume create $bakdir
  fi
  mkdir -p .snapshots

}

snapper_conf() {
  for i in "$@"; do
    if ! command -v $i &>/dev/null; then
      local name=${i//\//_}
      if [ ! -f "/etc/snapper/configs/$name" ]; then
        conf_file $i
      fi
    fi
  done
}

li="etc opt home root mnt mnt/data os"

snapper_conf $li

if [ ! -f "/etc/snapper/configs/disk" ]; then
  conf_file disk /
fi

cd $DIR
./init.py / $li

systemctl daemon-reload
mount -a
./snapshot.sh
