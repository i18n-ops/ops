#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

if [ -z "$1" ]; then
  echo "USAGE : $0 SQL"
  exit 1
fi

set -ex

. ../conf/mariadb/ip_li.sh
for ip in $MYSQL_IP_LI; do
  ssh root@$ip "sudo -u mariadb /usr/local/mariadb/bin/mariadb -e $@" || true
done
