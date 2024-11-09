#!/usr/bin/env bash
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. env.sh

export CARGO_DIST_FORCE_INSTALL_DIR=/opt/atuin
mkdir -p /opt/atuin
$CURL https://setup.atuin.sh | sh
