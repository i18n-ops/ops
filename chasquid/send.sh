#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

user=i@i18n.site \
  to=xxai.art@gmail.com \
  smtp=mail.i18n.site subject="测试 $(date)" direnv exec . ./sendmail.coffee
