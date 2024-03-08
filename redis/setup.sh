#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

redis_server=/usr/local/bin/redis-server

if [ -f "$redis_server" ]; then
  installed_version=$($redis_server --version | cut -d'=' -f2 | cut -d' ' -f1)
fi

ver=$(curl -s https://api.github.com/repos/redis/redis/releases/latest | grep tag_name | cut -d '"' -f 4)
if [ "$installed_version" == "$ver" ]; then
  echo "redis $ver is already installed"
else
  apt-get install -y libsystemd-dev pkg-config
  cd /tmp
  rm -rf redis-$ver redis.tar.gz
  wget https://github.com/redis/redis/archive/$ver.tar.gz -O redis.tar.gz
  tar zxvf redis.tar.gz
  cd redis-$ver
  USE_SYSTEMD=yes MALLOC=jemalloc make && make install
  rm -rf /tmp/redis-$ver
fi

$DIR/install.service.sh
