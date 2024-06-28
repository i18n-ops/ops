#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. ../orchestrator/master_ip.sh
cd ../ssh
direnv allow
direnv exec . ./u.sh "~/i18n/ops/iptable/iptable.sh $MASTER_IP $MASTER_PORT"
