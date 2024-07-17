#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

pdsh -w 'c0 c1 c2' 'set -x;kill `pidof obshell`;kill `pidof observer`'
