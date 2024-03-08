#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

cd /tmp
if [ -d "kvrocks" ]; then
  cd kvrocks
  git pull
else
  git clone -b unstable --depth=1 https://github.com/apache/kvrocks.git
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

cd $DIR
direnv allow
direnv exec . conf.sh
ulimit -n 102400
grep -q '^kvrocks' /etc/security/limits.conf || echo -e "\nkvrocks soft nofile 108224\nkvrocks hard nofile 108224" >>/etc/security/limits.conf

./service.sh
