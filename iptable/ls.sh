#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

# -v 可以看到包的数量 , 用于调试
iptables -t nat -L --line-numbers -v
