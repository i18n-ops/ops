#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

sudo -u mariadb /usr/local/mariadb/bin/mariadb -e "SHOW GLOBAL VARIABLES LIKE 'read_only'"
