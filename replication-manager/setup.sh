#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

version=$(curl -s https://api.github.com/repos/signal18/replication-manager/releases/latest | grep tag_name | cut -d '"' -f 4)

name=replication-manager
rm -rf /tmp/$name
mkdir -p /tmp
cd /tmp
git clone -b $version https://github.com/signal18/$name.git $name
cd $name
make bin
mv build/binaries/* /usr/local/bin

etcdir=/etc/replication-manager
mkdir -p $etcdir/cluster.d
if [ ! -d "$etcdir/config.toml" ]; then
  cp etc/config.toml $etcdir/config.toml

  conf=$etcdir/config.toml
  sed -i "/^api-credentials/c\\api-credentials = \"admin:$HTTPS_PASSWORD\"" $conf
  cat $DIR/failover.toml >>$conf

fi

# API_PASSWORD

#rm -rf /tmp/$name
