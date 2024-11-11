#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. /etc/profile

if ! id -u www-data >/dev/null 2>&1; then
  useradd -r -s /usr/sbin/nologin -M www-data
fi

mise trust

cd /opt

grep -q '/opt/ssl' ~/.gitconfig || git config --global --add safe.directory /opt/ssl

export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519"

if [ -d "ssl" ]; then
  $DIR/cron.sh
else
  git clone --depth=1 git@github.com:i18n-cron/ssl.git
  cd ssl
  chown -R www-data:www-data .
fi

minute=$((RANDOM % 60))
hour=$((RANDOM % 24))
day=$((RANDOM % 28 + 1))
cron_add "$minute $hour $day" $DIR cron.sh
