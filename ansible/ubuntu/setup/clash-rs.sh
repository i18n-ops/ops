#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

[ -z "$GFW" ] && exit 0

REPO=Watfaq/clash-rs
NAME=$(basename $REPO)

cd /tmp
rm -rf $NAME

REPO_URL="https://github.com/$REPO"
LATEST_VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name')

git clone git@github.com:$REPO.git --depth 1 -b $LATEST_VERSION

cargo_install --path /tmp/$NAME/clash
