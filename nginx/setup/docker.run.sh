#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

docker run --rm -it 3tisite/nginx /bin/bash
