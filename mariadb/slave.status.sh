#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

# Slave_IO_Running: 用于复制数据的I/O线程是否正在运行
# Slave_SQL_Running: 用于重放日志的SQL线程是否正在运行
# 如果两个值都是Yes,说明复制正常运行。

sudo -u mysql /usr/local/mysql/bin/mariadb -e 'show slave status \G' | rg "Running|Master_Log_File|Relay_Master_Log_File|Gtid"
