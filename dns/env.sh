#!/usr/bin/env bash

if [ -z "$HW_SK" ]; then
  DIR=$(dirname "${BASH_SOURCE[0]}")/..

  set -o allexport
  source $DIR/conf/hw.sh
  source $DIR/conf/cloudflare.sh
  set +o allexport
fi
