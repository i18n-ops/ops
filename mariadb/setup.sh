#!/usr/bin/env bash

set -ex

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

groupadd mariadb || true
useradd -r -g mariadb -M -N -s /bin/false mariadb || true
./compile.sh
./mariadb_conf.sh
./initdb.sh
