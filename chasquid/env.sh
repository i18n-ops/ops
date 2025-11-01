#!/usr/bin/env bash

set -e

if [ -n "$FORWORD_TO" ]; then
  exit
fi

set -o allexport
. $(dirname "${BASH_SOURCE[0]}")/../conf/chasquid/env.sh
set +o allexport
