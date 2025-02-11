#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

if [ -z "$GFW" ]; then
  RS=sh.rustup.rs
  CARGO_INSTALL="cargo binstall --no-confirm"
else
  RS=rsproxy.cn/rustup-init.sh
  export RUSTUP_DIST_SERVER="https://rsproxy.cn"
  export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
fi

if ! command -v cargo &>/dev/null; then
  $CURL https://$RS | sh -s -- -y --no-modify-path --default-toolchain nightly
  source $CARGO_HOME/env
  rustup component add rust-analyzer
fi

rustup default nightly
rustup update
