#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./btrfs.sh

crontab -l >cron/$(hostname)
git add cron && git commit -m. && git push || true
