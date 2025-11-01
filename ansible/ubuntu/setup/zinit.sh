#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

source env.sh
declare -A ZINIT
export ZPFX=/opt/zinit/polaris
export ZINIT_HOME=/opt/zinit/zinit.git
ZINIT[HOME_DIR]=/opt/zinit

if [ -d "$ZINIT_HOME" ]; then
  git -C $ZINIT_HOME pull
else
  git clone --depth=1 https://github.com/zdharma-continuum/zinit.git $ZINIT_HOME
fi

cat /root/.zinit.zsh | grep --invert-match "^zinit ice" | zsh

zsh -c "$(cat ~/.zinit.zsh | grep --invert-match "^zinit ice") && zinit self-update && zinit update --all && yes | zinit delete --clean && zinit compile --all"
