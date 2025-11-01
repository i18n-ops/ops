#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

host=s.i18n.site

cip() {
  curl -I https://$host --resolve "$host:443:$1"
  # curl --http3-only -I https://$host --resolve "$host:443:$1"
}

cip "[::1]"
cip 127.0.0.1
