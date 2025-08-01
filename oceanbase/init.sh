#!/usr/bin/env bash

set -ex

./sysctl.sh

obclient -h127.0.0.1 -P2881 -uroot -p$MYSQL_PWD -Doceanbase -A -e "\
ALTER SYSTEM SET syslog_level='warn';\
ALTER SYSTEM SET open_cursors=600;\
ALTER SYSTEM SET enable_sql_audit = false;"
