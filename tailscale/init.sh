#!/usr/bin/env bash

curl -fsSL https://tailscale.com/install.sh | bash

# DIR=$(realpath $0) && DIR=${DIR%/*}
# cd $DIR
# set -ex
#
# [ "$UID" -eq 0 ] || exec sudo "$0" "$@"
#
