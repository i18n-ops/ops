#!/usr/bin/env bash

# DIR=$(realpath $0) && DIR=${DIR%/*}
# cd $DIR
set -ex

. /etc/ops/mariadb/conf.sh

MAX_WAIT_TIME=60
WAIT_INTERVAL=1
ELAPSED_TIME=0

mariadb="sudo -u mariadb /usr/local/mariadb/bin/mariadb -e"
while true; do
  BEHIND_MASTER=$($mariadb "show slave status\G" | grep "Seconds_Behind_Master" | awk '{print $2}')
  if [[ -z "$BEHIND_MASTER" || "$BEHIND_MASTER" -eq 0 ]]; then
    break
  else
    echo "slave is $BEHIND_MASTER seconds behind the master. Waiting..."
  fi

  if [ "$ELAPSED_TIME" -ge "$MAX_WAIT_TIME" ]; then
    echo "maximum wait time of $MAX_WAIT_TIME seconds reached. Exiting."
    break
  fi

  sleep $WAIT_INTERVAL
  ELAPSED_TIME=$((ELAPSED_TIME + WAIT_INTERVAL))
done

$mariadb "STOP SLAVE;RESET SLAVE ALL;SET GLOBAL read_only=OFF;"
