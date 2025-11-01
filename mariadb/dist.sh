#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
source $DIR/VER.sh

set -ex

cd /tmp/mariadb-$VER

name=mariadb-$VER-ubuntu-$(echo $(lsb_release -rs | cut -d '.' -f 1,2 | tr '\n' '.' | sed 's/\.$//')).tgz

if [ ! -f "$name" ]; then
  mv mariadb-$VER-linux-$(uname -m).tar.gz $name
fi

repo=i18n-ops/ops
release=mariadb-$VER
gh release create $release --notes $release -R $repo
gh release upload -R $repo $release $name
rm $name
