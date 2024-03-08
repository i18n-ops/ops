#!/usr/bin/env bash

rconf() {
  sed -i "$1" /etc/kvrocks/kvrocks.conf
}

ensure() {
  mkdir -p $1
  chown -R kvrocks:kvrocks $1
}

LOG_DIR=/var/log/kvrocks
ensure $LOG_DIR

DATA_DIR=/mnt/data/i18n/kvrocks
ensure $DATA_DIR

rconf '/^rocksdb.compression /c\rocksdb.compression zstd'
rconf '/^rocksdb.enable_blob_files /c\rocksdb.enable_blob_files yes'
rconf '/^rocksdb.read_options.async_io /c\rocksdb.read_options.async_io yes'
rconf '/^bind /c\bind 0.0.0.0'
rconf '/^db-name /c\db-name i18n.db'
rconf '/^supervised /c\supervised systemd'
rconf '/^daemonize /c\daemonize yes'
rconf '/^cluster-enabled /c\cluster-enabled yes'
rconf "/^workers /c\\workers $(nproc)"
rconf "/^port /c\\port $R_PORT"
rconf "/^dir /c\\dir $DATA_DIR"
rconf "/^log-dir /c\\log-dir $LOG_DIR"

rconf '/^#\?\s*resp3-enabled\s/c\resp3-enabled yes'
rconf "/^#\\?\\s*requirepass /c\\requirepass $R_PASSWORD"
