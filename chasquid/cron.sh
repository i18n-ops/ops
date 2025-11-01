#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
set -ex

minute=$((RANDOM % 60))
hour=$((RANDOM % 24))

cron_add "$minute $hour */30" $DIR restart.sh
