#!/usr/bin/env bash

set -ex

ssh c0 "~/i18n/ops/oceanbase/sql.log.sh"

mkdir -p /tmp/ob
cd /tmp/ob

rsync="rsync -Pavz --compress-choice=zstd --compress-level=9 --checksum-choice=xxh3"
$rsync c0:/tmp/sql.log/* .

vps_li="c0 c1 c2"

for vps in $vps_li; do
  to=/tmp/ob/$vps
  rm -rf $to
  mkdir -p $to
  $rsync --delete "$vps:/opt/ob/oceanbase/log/observer.log" $to &
done

wait

# tar --use-compress-program=pbzip2 -cf ../ob.tar.bz2 .

7z a -t7z -m0=lzma2 -mmt=on -mx=7 -mfb=64 -md=32m -ms=on ../ob.7z .
