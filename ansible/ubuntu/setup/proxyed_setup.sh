#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./i_if_not_exist.sh atuin mise rg czmod
./misei.sh
./zinit.sh
