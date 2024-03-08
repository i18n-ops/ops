#!/usr/bin/env bash

VERSION=8.2.0-1

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

echo never >/sys/kernel/mm/transparent_hugepage/enabled
apt-get install -y libaio-dev libkrb5-dev libldap-dev libprotobuf-dev \
  libsasl2-dev libsasl2-modules-gssapi-mit libevent-dev libudev-dev

cd /tmp

if [ ! -d "percona-server" ]; then
  git clone --depth=1 -b release-$VERSION https://github.com/percona/percona-server.git
fi

cd percona-server

cd cmake
rm boost.cmake
wget https://raw.githubusercontent.com/percona/percona-server/8.0/cmake/boost.cmake
cd ..

git submodule init
git submodule update

cd ..
mkdir -p percona-build
cd percona-build

cmake ../percona-server \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DBUILD_CONFIG=mysql_release \
  -DMYSQL_MAINTAINER_MODE=OFF \
  -DDOWNLOAD_BOOST=ON \
  -DWITH_BOOST=../deps \
  -DWITH_SYSTEM_LIBS=ON \
  -DWITHOUT_TOKUDB=ON \
  -DWITH_ROCKSDB=ON \
  -DWITH_FIDO=bundled \
  -DWITH_PROTOBUF=bundled

cmake --build . -- -j $(nproc)

# ./mysql-test –debug-server rocksdb.1st
