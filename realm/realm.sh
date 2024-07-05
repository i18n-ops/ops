#!/usr/bin/env bash
set -ex
CONF_DIR=/etc/realm
cd $CONF_DIR/pre
find . -type f -executable -exec {} \;
exec /usr/local/bin/realm -c $CONF_DIR/conf.toml
