#!/usr/bin/env bash

set -ex

DISK=$(fdisk -l /dev/sda | grep -E '^/dev/' | awk '$6 == "Linux" {print $1, $4}' | sort -k2,2n | tail -n1 | awk '{print $1}')

[ "$(lsblk -no FSTYPE $DISK)" = "ext4" ] || {
  echo "Error: $DISK is not an ext4 filesystem."
  exit 1
}

e2fsck -f $DISK -y || true

MNT="/mnt"

OPTIONS_BTRFS="defaults,ssd,discard,noatime,compress=zstd:3,autodefrag,space_cache=v2"

btrfs-convert $DISK

mount $DISK $MNT -t btrfs -o $OPTIONS_BTRFS

# 会生成新的 /boot/grub/grub.cfg.new
BOOT=$(fdisk -l | awk '/^\/dev\// && /Linux extended boot/ {print $1}')
mkdir -p $MNT/boot
mount $BOOT $MNT/boot -t ext4 -o defaults,noatime

for item in proc dev sys; do
  mount --rbind /$item $MNT/$item
  [[ "$item" == "dev" || "$item" == "sys" ]] && mount --make-rslave $MNT/$item
done

rm $MNT/etc/resolv.conf
cp /etc/resolv.conf $MNT/etc

backup_file="$MNT/etc/fstab.bak"
fstab_file="$MNT/etc/fstab"
cp $fstab_file $backup_file

awk '
{
  if ($2 == "/") {
    $1="'$DISK'";
    $3="btrfs";
    $4="'$OPTIONS_BTRFS'";
    $5="0";
    $6="0";
  }
  print;
}' $backup_file >$fstab_file

cd $MNT

_sub() {
  local bname=$(basename $1)
  local dname=$(dirname $1)
  mkdir -p $1 || true
  old=$dname/_$bname
  mv $1 $old
  btrfs subvolume create $1
}

subvolume() {
  for i in "$@"; do
    _sub $i
    cp -a --reflink $old/. $i
    rm -rf $old
  done
}

subvolume root home opt var/log

# 移除NoCOW属性，使得该目录下的文件在写入时不会复制原始数据，而是直接覆盖，这对于日志文件的写入行为更为高效。 https://wiki.archlinux.org/title/btrfs
# lsattr -l /var/ 可以查看是否禁用成功
nocow() {
  for i in "$@"; do
    _sub $i
    chattr +C $i
    cp -a --reflink=never $old/. $i
    rm -rf $old
  done
}

nocow var/log var/cache var/tmp var/lib/docker var/lib/apt tmp root/.local root/.cache cache mnt/data

wget https://raw.githubusercontent.com/i18n-ops/ops/main/contabo/init.btrfs.sh -O init.btrfs.sh

chmod +x init.btrfs.sh

chroot $MNT /init.btrfs.sh
