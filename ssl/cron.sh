#!/usr/bin/env bash

set -ex

branch=main

export GIT_SSH_COMMAND="ssh -i /root/.ssh/id_ed25519.i18n"

cd /opt/ssl

git fetch --depth=1 origin $branch

if [ $(git rev-list HEAD...origin/$branch --count) -gt 0 ]; then
  git reset --hard FETCH_HEAD
  git prune
  git gc --aggressive
  chown -R www-data:www-data .
  lsof -i:443 -sTCP:LISTEN >/dev/null && systemctl reload nginx
fi
