#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -e
. ../conf/iptable/db.sh

SELF_IP=$(ip addr show | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | while read -r ip; do [[ " $MYSQL_HOST_LI " == *" $ip "* ]] && echo $ip; done)

isMaster() {
  local result
  ip=$1
  result=$(/usr/local/mysql/bin/mariadb -h$ip -P$MYSQL_PORT -u$MYSQL_USER -e "SHOW SLAVE STATUS\G" || echo "failed")

  if [ -z "$(echo "$result" | grep "Slave_IO_State")" ]; then
    echo "$ip:$port IS A MASTER"

    ./iptable.sh 2884 $ip $MYSQL_PORT

    if [ "$ip" != "$SELF_IP" ]; then
      [[ " $MYSQL_HOST_LI " == *" $SELF_IP "* ]] && MASTER_IP=$ip ../mariadb/slave.cnf.sh
    fi
    exit 0
  else
    echo "$ip $result"
  fi
}

for ip in $MYSQL_HOST_LI; do
  if [ "$ip" != "$SELF_IP" ]; then
    isMaster $ip
  fi
done

isMaster $SELF_IP
