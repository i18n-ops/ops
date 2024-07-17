#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

source $DIR/VER.sh

mkdir -p /tmp/mariadb

cd /tmp/mariadb

name=mariadb-$VER-ubuntu-$(echo $(lsb_release -rs | cut -d '.' -f 1,2 | tr '\n' '.' | sed 's/\.$//')).tgz

wget -c https://github.com/i18n-ops/ops/releases/download/mariadb-$VER/$name

groupadd mysql || true
useradd -r -g mysql -M -N -s /bin/false mysql || true
rm -rf /usr/local/mysql
mkdir -p /usr/local/mysql
tar -xvzf $name -C /usr/local/mysql --strip-components=1
chown -R mysql:mysql /usr/local/mysql
rm -rf /tmp/mariadb
