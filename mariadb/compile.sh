#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}

set -ex

apt-get install -y cmake bison libjemalloc-dev libzstd-dev liblz4-dev libcurl4-gnutls-dev jq

cd /tmp

GITDIR=$(curl -sS "https://api.github.com/repos/MariaDB/server/releases?per_page=100" | jq -r '.[].tag_name' | grep -v -E 'alpha|beta|rc|RC' | grep -P '^mariadb-\d' | sort -V | tail -n 1)

if [ ! -d "$GITDIR" ]; then
  git clone -b $GITDIR --depth=1 https://github.com/MariaDB/server.git $GITDIR
fi

cd $GITDIR

git submodule init
git submodule update

# apt-get install -y wget vim net-tools bash* build-essential cmake bison libncurses5-dev libssl-dev pkg-config libxml2-dev zlib1g-dev libbz2-dev libcurl4-gnutls-dev libjpeg-dev libpng-dev libgmp-dev libgmp3-dev libmcrypt-dev mcrypt libedit-dev libreadline-dev libxslt1-dev libpcre3 libpcre3-dev libfreetype6-dev

# -DCLIENT_PLUGIN_ZSTD=STATIC \
# git clean -d -f -x

LIBDIR=/usr/lib/$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -o | sed 's/\/.*$//' | tr '[:upper:]' '[:lower:]')

BASE=/usr/local/mariadb
FLAG="-O3 -flto -pipe"
cmake . \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="$FLAG" \
  -DCMAKE_C_FLAGS="$FLAG" \
  -DCMAKE_INSTALL_PREFIX=$BASE \
  -DSYSCONFDIR=/etc/mariadb \
  -DINSTALL_PLUGINDIR=lib/plugin \
  -DSYSCONFDIR=/etc \
  -DWITH_ROCKSDB_ZSTD=ON \
  -DWITH_ROCKSDB_LZ4=ON \
  -DCONNECT_WITH_MYSQL=ON \
  -DSKIP_TESTS=ON \
  -DWITH_READLINE=ON \
  -DTMPDIR=/var/tmp \
  -DPLUGIN_ROCKSDB=YES \
  -DMYSQL_TCP_PORT=3306 \
  -DPLUGIN_PARTITION=STATIC \
  -DWITH_INNOBASE_STORAGE_ENGINE=0 \
  -DWITH_SPIDER_STORAGE_ENGINE=0 \
  -DWITH_MROONGA_STORAGE_ENGINE=0 \
  -DWITH_MYISAM_STORAGE_ENGINE=0 \
  -DPLUGIN_SPHINX=NO \
  -DPLUGIN_TOKUDB=NO \
  -DPLUGIN_AUTH_GSSAPI=NO \
  -DPLUGIN_AUTH_GSSAPI_CLIENT=OFF \
  -DEXTRA_CHARSETS=all \
  -DWITH_SSL=system \
  -DWITH_BOOST=boost \
  -DDEFAULT_CHARSET=utf8mb4 \
  -DDEFAULT_COLLATION=utf8mb4_bin \
  -DMYSQL_UNIX_ADDR=/run/mariadb/mariadb.sock \
  -DOWNLOAD_BOOST=1 -DENABLE_DOWNLOADS=1 \
  -DWITH_ROCKSDB_JEMALLOC=yes \
  -DCMAKE_EXE_LINKER_FLAGS='-ljemalloc' \
  -DWITH_SAFEMALLOC=OFF

make -j $(nproc)
make install
