#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

cd /tmp

ver=$(curl -s https://api.github.com/repos/apache/kvrocks/releases/latest | grep -o '"tag_name": "[^"]*' | cut -d '"' -f 4)

if [ -d "kvrocks" ]; then
  cd kvrocks
  git checkout $ver
  git pull origin $ver
else
  git clone -b $ver --depth=1 https://github.com/apache/kvrocks.git
  cd kvrocks
fi

if ! id -u kvrocks >/dev/null 2>&1; then
  useradd kvrocks
fi

if ! getent group kvrocks >/dev/null 2>&1; then
  groupadd kvrocks
fi

export CFLAGS="-march=native -O3"
export CXXFLAGS="-march=native -O3"

./x.py build -DENABLE_OPENSSL=ON -DPORTABLE=1 -DCMAKE_BUILD_TYPE=Release -j $(nproc)
mv build/kvrocks /usr/local/bin
mkdir -p /etc/kvrocks
cp kvrocks.conf /etc/kvrocks/
chown -R kvrocks:kvrocks /etc/kvrocks

$DIR/conf.sh

ulimit -n 102400
grep -q '^kvrocks' /etc/security/limits.conf || echo -e "\nkvrocks soft nofile 108224\nkvrocks hard nofile 108224" >>/etc/security/limits.conf

$DIR/service.sh kvrocks
mkdir -p /mnt/data/i18n/kvrocks
chown -R kvrocks:kvrocks /mnt/data/i18n/kvrocks

$DIR/sentinel.sh
