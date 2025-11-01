#!/usr/bin/env bash

set -ex

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

./conf.sh
./setup.sh i18n-api/pay_webhook $@
