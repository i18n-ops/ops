#!/usr/bin/env bash
export CARGO_HOME=/opt/rust
export RUSTUP_HOME=$CARGO_HOME
export RUSTFLAGS="-C linker=clang -C link-arg=-fuse-ld=/usr/bin/mold"
[ -f "/opt/rust/env" ] && source /opt/rust/env || true
