#!/usr/bin/env bash
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex
source ../conf/oceanbase.sh
cd /opt/oceanbase/$OB_CLUSTER/obagent
exec ./bin/ob_agentd -c ./conf/agentd.yaml
