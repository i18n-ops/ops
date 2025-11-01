#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
set -ex

cron_add "0 6 *" $DIR backup.sh
