#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./pssh.sh os/ALL.sh "systemctl disable docker.socket;systemctl disable docker"
