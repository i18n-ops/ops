#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. /etc/ops/kvrocks/conf.sh
. /etc/ops/kvrocks/sentinel.sh

if ! command -v redis-sentinel &>/dev/null; then
  apt-get update -y
  apt-get install -y redis-sentinel
  systemctl disable redis-sentinel
  systemctl stop redis-sentinel
fi

user=kvrocks-sentinel

if ! id -u $user >/dev/null 2>&1; then
  useradd $user
fi

if ! getent group $user >/dev/null 2>&1; then
  groupadd $user
fi

initdir() {
  mkdir -p $1
  chown -R $user:$user $1
}

LOGDIR=/var/log/kvrocks-sentinel
initdir $LOGDIR

CONF=/etc/kvrocks-sentinel
initdir $CONF

cp sentinel.conf $CONF
chown $user:$user $CONF/sentinel.conf

rconf() {
  sed -i "$1" $CONF/sentinel.conf
}

# https://redis.io/docs/management/sentinel/

rconf "/^#\?\s*requirepass /c\\requirepass $R_SENTINEL_PASSWORD"
rconf "/^#\?\s*sentinel auth-pass\s/c\\sentinel auth-pass $R_SENTINEL_NAME $R_PASSWORD"
rconf "/^#\?\s*sentinel sentinel-pass mymaster\s/c\\sentinel sentinel-pass $R_SENTINEL_PASSWORD"
rconf "/^port /c\\port $R_SENTINEL_PORT"
rconf "/^dir /c\\dir $LOGDIR"
rconf "/^logfile /c\\logfile $LOGDIR/sentinel.log"
# 在Redis哨兵的配置文件中，sentinel monitor命令的最后一个参数是quorum，它表示需要多少个哨兵节点同意才能执行故障转移。如果你有3个哨兵节点，那么你应该将quorum设置为2。这是因为在一个3节点的哨兵集群中，只有当至少2个哨兵节点同意主节点已经掉线时，才会触发故障转移。这样设置可以确保在故障转移过程中，即使有一个哨兵节点出现故障或者网络分区，也不会误判主节点的状态，从而避免不必要的故障转移。

rconf "/^sentinel monitor mymaster /c\\sentinel monitor $R_SENTINEL_NAME $R_MASTER_IP $R_PORT 2"
rconf '/^protected-mode /c\protected-mode no'
rconf "s/mymaster/$R_SENTINEL_NAME/g"
./service.sh $user
