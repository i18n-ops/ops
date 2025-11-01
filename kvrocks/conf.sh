#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -ex

ETC_OPS=/etc/ops/kvrocks
. $ETC_OPS/conf.sh
. $ETC_OPS/sentinel.sh

CONF=/etc/kvrocks/kvrocks.conf

rconf() {
  sed -i "$1" $CONF
}

disable_cmd() {
  for cmd in "$@"; do
    grep -q "^\s*rename-command $cmd " $CONF || echo -e "\nrename-command $cmd \"\"\n" >>$CONF
  done
}

disable_cmd FLUSHDB FLUSHALL

initdir() {
  mkdir -p $1
  chown -R kvrocks:kvrocks $1
}

LOG_DIR=/var/log/kvrocks
initdir $LOG_DIR

DATA_DIR=/mnt/data/i18n/kvrocks
initdir $DATA_DIR

rconf '/^rocksdb.compression /c\rocksdb.compression zstd'
rconf '/^rocksdb.enable_blob_files /c\rocksdb.enable_blob_files yes'
rconf '/^rocksdb.read_options.async_io /c\rocksdb.read_options.async_io yes'
rconf '/^repl-namespace-enabled /c\repl-namespace-enabled yes'
rconf '/^bind /c\bind 0.0.0.0'
rconf '/^db-name /c\db-name i18n.db'
rconf '/^supervised /c\supervised systemd'
rconf '/^daemonize /c\daemonize yes'
rconf '/^migrate-type /c\migrate-type raw-key-value'
rconf "/^workers /c\\workers $(nproc)"
rconf "/^port /c\\port $R_PORT"
rconf "/^dir /c\\dir $DATA_DIR"
rconf "/^log-dir /c\\log-dir $LOG_DIR"

rconf '/^#\?\s*resp3-enabled\s/c\resp3-enabled yes'
rconf "/^#\\?\\s*requirepass /c\\requirepass $R_PASSWORD"

rconf "/^#\?\s*masterauth /c\\masterauth $R_PASSWORD"

if ! ip addr show | awk '/inet / {print $2}' | cut -d'/' -f1 | grep -q "$R_MASTER_IP"; then
  rconf "/^#\?\s*slaveof [^<]/c\\slaveof $R_MASTER_IP $R_PORT"
fi
