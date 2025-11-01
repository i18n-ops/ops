#!/usr/bin/env bash

set -ex

if [ -z "$2" ]; then
  echo "USAGE : $0 PASSWORD_FILE FILE"
  exit 1
fi

if [ ! -f "$2" ]; then
  echo "$2 is not file"
  exit
fi

cd $(dirname $2)
FNAME=$(basename "$2")
NAME=_$FNAME

rm -rf $NAME
mkdir -p $NAME

gpg --decrypt --batch --passphrase-file "$1" "$2" | zstd -dc | tar -xv -C $NAME/

rm -rf $FNAME
mv $NAME $FNAME
