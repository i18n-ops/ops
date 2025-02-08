#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

BKDIR=/tmp/bak/i18n
rm -rf $BKDIR

../kvrocks/backup.sh
../mariadb/backup.sh

github_bak $BKDIR

rm -rf $BKDIR
