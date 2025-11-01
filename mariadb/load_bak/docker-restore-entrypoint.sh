#!/bin/bash
set -ex

# 检查数据目录是否为空。如果是，则从备份中恢复。
# 我们忽略'lost+found'目录，它可能存在于新创建的文件系统中。
if [ -z "$(ls -A /var/lib/mysql | grep -v lost+found)" ]; then
  echo "数据目录为空，正在从/backup恢复MyRocksDB备份..."

  BACKUP_SRC=/backup
  cp -R $BACKUP_SRC /var/lib/mysql_tmp

  # 使用复制到镜像中的 myrocks_hotbackup 脚本进行恢复。
  python3 /usr/local/bin/myrocks_hotbackup --move_back \
    --datadir=/var/lib/mysql \
    --rocksdb_datadir=/var/lib/mysql/#rocksdb \
    --rocksdb_waldir=/var/lib/mysql \
    --backup_dir="/var/lib/mysql_tmp"

  chown -R mysql:mysql /var/lib/mysql
  rm -rf /var/lib/mysql_tmp
fi

exec docker-entrypoint.sh "$@"
