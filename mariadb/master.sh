#!/usr/bin/env bash

# DIR=$(realpath $0) && DIR=${DIR%/*}
# cd $DIR
set -ex

sudo -u mysql /usr/local/mysql/bin/mariadb -e "STOP SLAVE;SET GLOBAL read_only=OFF;"
