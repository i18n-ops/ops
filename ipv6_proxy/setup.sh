#!/usr/bin/env bash
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -ex

./init.os.sh
./init.conf.sh

mkdir -p /opt

export RUSTFLAGS="$RUSTFLAGS -C target-cpu=native"

cargo install --root /opt --force ipv6_proxy

rsync -avz $DIR/os/ /

ipv6_proxy_sh=/opt/bin/ipv6_proxy.sh

chmod +x $ipv6_proxy_sh

sed -i "s/USER=root/USER=$USER/g" /opt/bin/ipv6_proxy.sh

systemctl daemon-reload
systemctl enable --now ipv6_proxy
systemctl status ipv6_proxy --no-pager || true
