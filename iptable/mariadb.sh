#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. /etc/ops/mariadb/conf.sh
. /etc/ops/mariadb/mariadb.sh

SELF_IP=$(ip addr show | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | while read -r ip; do [[ " $MARIADB_IP_LI " == *" $ip "* ]] && echo $ip && break; done)

setMaster() {
  for ip in $MARIADB_IP_LI; do
    cmd="/opt/ops/iptable/iptable.sh $MYSQL_PORT $1 $MARIADB_PORT"
    if [ "$ip" != "$1" ]; then
      cmd="$cmd && /opt/ops/mariadb/slave.sh $1"
    fi
    ssh $ip "$cmd"
  done
}

fdMaster() {
  local result
  ip=$1
  result=$(/usr/local/mysql/bin/mariadb -h$ip -P$MARIADB_PORT -usync -e "SHOW SLAVE STATUS\G" || echo "Slave_IO_State")

  if [ -z "$(echo "$result" | grep "Slave_IO_State")" ]; then
    echo "$ip:$port IS A MASTER"
    setMaster $ip
    exit 0
  fi
}

for ip in $MARIADB_IP_LI; do
  # 避免一启动就把自己提升为主
  if [ "$ip" != "$SELF_IP" ]; then
    fdMaster $ip
  fi
done

./master.sh
fdMaster $SELF_IP
