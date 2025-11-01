#!/usr/bin/env bash

set -ex
curl -fsSL https://tailscale.com/install.sh | bash

tailscale down
# 不禁用 DNS  感觉会导致很多问题
tailscale up --accept-dns=false

# DIR=$(realpath $0) && DIR=${DIR%/*}
# cd $DIR
# set -ex
#
# [ "$UID" -eq 0 ] || exec sudo "$0" "$@"
#
