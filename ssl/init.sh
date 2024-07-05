#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex
mise trust
cd /opt

grep -q '/opt/ssl' ~/.gitconfig || git config --global --add safe.directory /opt/ssl

export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519.i18n"

if [ -d "ssl" ]; then
  $DIR/cron.sh
else
  git clone --depth=1 git@github.com:i18n-cron/ssl.git
  cd ssl
  chown -R www-data:www-data .
fi

minute=$((RANDOM % 60))
hour=$((RANDOM % 24))

cron_add "$minute $hour */19" $DIR cron.sh
