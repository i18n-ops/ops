#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

../mariadb/master.sh

msg=$(sudo -u mysql /usr/local/mysql/bin/mariadb -e "show slave status\G")
. ../conf/iptable/db.sh

IP=$(ip addr show | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | while read -r ip; do [[ " $MYSQL_HOST_LI " == *" $ip "* ]] && echo $ip; done)

../ssh/c.sh "~/i18n/ops/iptable/iptable.sh 2884 $IP $MYSQL_PORT"
