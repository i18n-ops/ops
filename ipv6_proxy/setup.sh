#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
. /etc/profile

set -ex

./init.os.sh

mkdir -p /opt

export RUSTFLAGS="$RUSTFLAGS -C target-cpu=native"

cd /tmp

if [ -d "ipv6_proxy" ]; then
  cd ipv6_proxy
  git fetch --all && git reset --hard origin/dev
else
  git clone -b dev --depth=1 git@atomgit.com:i18n-in/ipv6_proxy.git
  cd ipv6_proxy
fi

cargo install --root /opt --force --path .

rsync -av --chown=root:root $DIR/os/ /

ipv6_proxy_sh=/opt/bin/ipv6_proxy.sh

chmod +x $ipv6_proxy_sh

sed -i "s/USER=root/USER=$USER/g" /opt/bin/ipv6_proxy.sh

systemctl daemon-reload
systemctl enable --now ipv6_proxy
systemctl status ipv6_proxy --no-pager || true
