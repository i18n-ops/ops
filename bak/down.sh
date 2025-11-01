#!/usr/bin/env bash

set -e
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
ROOT=${DIR%/*}
for dir in ../conf /etc/ops; do
  if [ -f "$dir/bak/env.sh" ]; then
    CONFDIR=$(realpath $dir)/bak
    . $CONFDIR/env.sh
    break
  fi
done
set -x

TAG=$(gh release --repo $GITHUB_REPO list -L 1 --json tagName -q '.[0].tagName')

TMP=/tmp/bak/$TAG

rm -rf $TMP
mkdir -p $TMP

cd $TMP

gh release --repo $GITHUB_REPO download $TAG --skip-existing

find $TMP \
  -maxdepth 1 -type f \
  -exec bash \
  -c "$DIR/decode.sh $CONFDIR/gpgPassowrd \$0" {} \;

cd *
ls
LOAD_BAK=$ROOT/mariadb/load_bak
rm -rf $LOAD_BAK/mariadb
mv mariadb $LOAD_BAK

cat <<EOF

DOWNLOAD FILE SUCCESS

load mariadb → ../mariadb/load_bak
load kvrocks → $TMP

EOF
