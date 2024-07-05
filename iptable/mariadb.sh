#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. ../orchestrator/master_ip.sh
./iptable.sh $MASTER_IP $MASTER_PORT
