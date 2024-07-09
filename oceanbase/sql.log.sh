#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
source ~/i18n/conf/env/db.sh
set -ex

todir=/tmp/sql.log
rm -rf $todir
mkdir -p $todir

exec mysql -h$MYSQL_HOST -P2881 -u$MYSQL_USER -Doceanbase -A -e \
  'SELECT RET_CODE,DATE_FORMAT(FROM_UNIXTIME(request_time/1000000),"%Y-%m-%d %H:%i:%s") as REQ_TIME,ELAPSED_TIME,NET_WAIT_TIME,NET_TIME,GET_PLAN_TIME,USER_IO_WAIT_TIME,QUEUE_TIME,EXECUTE_TIME,WAIT_TIME_MICRO,DECODE_TIME,TABLE_SCAN,PLAN_TYPE,RETURN_ROWS,AFFECTED_ROWS,DISK_READS,PLAN_ID,SQL_ID,TRACE_ID,REQUEST_ID,SQL_EXEC_ID,query_sql FROM v$OB_SQL_AUDIT' | sed 's/\t/,/g' >$todir/sql_audit.csv
