#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

[ -z "$GFW" ] && exit 0

REPO=Watfaq/clash-rs
REPO_URL="https://github.com/$REPO"
LATEST_VERSION=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.tag_name')

cargo_install_github $REPO.git --tag "$LATEST_VERSION"
