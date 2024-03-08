#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

source ../conf/oceanbase.sh

e() {
  obclient -h127.0.0.1 -P2883 -uroot -p$OBPROXY_SYS_PASSWORD -Doceanbase -A -e "$1"
}

e "ALTER SYSTEM SET syslog_level='warn'"
