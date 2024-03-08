#!/usr/bin/env bash

VERSION=11.4.1

set -ex

apt-get install -y bison libjemalloc-dev libzstd-dev libcurl4-gnutls-dev

cd /tmp

GITDIR=mariadb-$VERSION

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

BASE=/usr/local/mysql
cmake . \
  -DCMAKE_INSTALL_PREFIX=$BASE \
  -DINSTALL_PLUGINDIR=lib/plugin \
  -DSYSCONFDIR=/etc \
  -DWITH_ROCKSDB_ZSTD=ON \
  -DWITH_ROCKSDB_LZ4=OFF \
  -DCONNECT_WITH_MYSQL=ON \
  -DSKIP_TESTS=ON \
  -DWITH_READLINE=ON \
  -DTMPDIR=/var/tmp \
  -DPLUGIN_ROCKSDB=YES \
  -DMYSQL_TCP_PORT=3306 \
  -DPLUGIN_PARTITION=STATIC \
  -DWITH_INNOBASE_STORAGE_ENGINE=0 \
  -DWITH_MYISAM_STORAGE_ENGINE=0 \
  -DPLUGIN_SPHINX=NO \
  -DPLUGIN_TOKUDB=NO \
  -DPLUGIN_AUTH_GSSAPI=NO \
  -DPLUGIN_AUTH_GSSAPI_CLIENT=OFF \
  -DEXTRA_CHARSETS=all \
  -DDEFAULT_CHARSET=binary \
  -DWITH_SSL=system \
  -DWITH_BOOST=boost \
  -DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock \
  -DOWNLOAD_BOOST=1 -DENABLE_DOWNLOADS=1 \
  -DWITH_ROCKSDB_JEMALLOC=yes \
  -DCMAKE_EXE_LINKER_FLAGS='-ljemalloc' -DWITH_SAFEMALLOC=OFF

make -j $(nproc) package

gh release upload --repo
