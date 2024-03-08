#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

sudo -u mysql mysql -e 'show slave status \G'
