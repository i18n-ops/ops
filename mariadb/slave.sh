#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. ../../conf/env/db.init.sh
. ../../conf/env/db.sh
./slave.cnf.sh

systemctl restart mariadb
