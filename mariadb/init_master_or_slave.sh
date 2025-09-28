#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

. /etc/ops/mariadb/conf.sh
. /etc/ops/mariadb/mariadb.sh

set -ex

for ip in $MYSQL_IP_LI; do
  result=$(/usr/local/mariadb/bin/mariadb -h$ip -P$MYSQL_PORT -usync -e "SHOW SLAVE STATUS\G" || echo "Slave_IO_State")

  if [ -z "$(echo "$result" | grep "Slave_IO_State")" ]; then
    echo "$ip:$MYSQL_PORT IS A MASTER"
    for local_ip in $(ip addr show | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1); do
      if [ "$local_ip" = "$ip" ]; then
        echo "SELF $ip is MASTER"
        ./master.sh
        exit
      fi
    done
    ./slave.sh $ip
    exit
  fi
done

./init.master.sh
