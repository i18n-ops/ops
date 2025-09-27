#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

if ! id -u realm >/dev/null 2>&1; then
  useradd realm
fi

if ! command -v realm &>/dev/null; then

  rm -rf /tmp/realm

  cd /tmp
  git clone --depth=1 https://github.com/zhboner/realm && cd realm
  RUSTFLAGS='-C target_cpu=native' cargo build --release --features=mimalloc
  mv ./target/release/realm /usr/local/bin/

fi

cp -f $DIR/realm.sh /usr/local/bin

ensure() {
  mkdir -p $1
  chown -R realm $1
}
ensure /var/log/realm
ensure /etc/realm
rm -rf /etc/realm/pre
ln -s $DIR/pre /etc/realm/pre

cd $DIR
conf=/etc/realm/conf.toml
if [ ! -f "$conf" ]; then
  cp conf.toml $conf
fi
chown realm $conf
./service.sh realm
