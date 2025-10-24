#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -ex

for dir in ../conf /etc/ops; do
  if [ -f "$dir/bak/env.sh" ]; then
    CONFDIR=$(realpath $dir)/bak
    . $CONFDIR/env.sh
    break
  fi
done

TAG=$(gh release --repo $GITHUB_REPO list -L 1 --json tagName -q '.[0].tagName')

TMP=/tmp/bak/$TAG

mkdir -p $TMP

cd $TMP

gh release --repo $GITHUB_REPO download $TAG --skip-existing

find $TMP \
  -maxdepth 1 -type f \
  -exec bash \
  -c "$DIR/decode.sh $CONFDIR/gpgPassowrd \$0" {} \;

ls

echo -e "\e[32m\nDownload File Success ! Please Run:\n\ncd $TMP && ls\n\e[0m"
