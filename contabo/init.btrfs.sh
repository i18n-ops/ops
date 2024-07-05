#!/usr/bin/env bash

set -ex
apt install -y dnf
sed -i '/save_env recordfail/s/^/#/' /etc/grub.d/00_header
update-grub
grub-install /dev/sda
apt install -y btrfs-progs
btrfs subvolume delete /ext2_saved || true
btrfs filesystem defragment -r -v -f -czstd / >/dev/null
btrfs balance start -m /
rm $(realpath $0)
