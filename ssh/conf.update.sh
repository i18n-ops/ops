#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

./pssh.sh os/MAIL.sh "cd ~/i18n && [ -d conf ] && ( cd conf && git fetch --all && git reset --hard origin/main ) || git clone git@atomgit.com:i18n-api/conf.git"
