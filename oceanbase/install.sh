#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

# 通过 OBD 白屏部署 OceanBase 集群 https://www.oceanbase.com/docs/common-oceanbase-database-cn-1000000000821384

cd /tmp

wget -c https://obbusiness-private.oss-cn-shanghai.aliyuncs.com/download-center/opensource/oceanbase-all-in-one/8/x86_64/oceanbase-all-in-one-4.3.1.0-100000032024051615.el8.x86_64.tar.gz -O ob.tgz

tar zxf ob.tgz

cd oceanbase-all-in-one/bin
./install.sh

source ~/.oceanbase-all-in-one/bin/env.sh && obd web
