#!/usr/bin/env bash

set -ex

if [ -n "$1" ]; then
  REPO=$1
else
  echo "USAGE : $0 org/repo [$ver]"
  exit 1
fi

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

REPO_NAME=$(basename $REPO)

if [ -n "$2" ]; then
  VER=$2
else
  VER=$(curl -sS https://api.github.com/repos/$REPO/releases/latest | jq -r '.tag_name')
fi

tmpdir=/tmp/$REPO
rm -rf $tmpdir
mkdir -p $tmpdir
cd $tmpdir

name=x86_64-unknown-linux-gun
file=$name.tar.zst.gpg

wget -c https://github.com/$REPO/releases/download/$VER/$file
mkdir -p $name

gpg --decrypt --batch --passphrase-file /etc/ops/dist/gpgPassowrd $file |
  tar --use-compress-program=zstd -xv -C $name

rm -f $file
rsync -av --remove-source-files $name/ /
systemctl daemon-reload
systemctl restart $REPO_NAME
rm -rf $name
