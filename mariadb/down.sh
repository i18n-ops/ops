#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

# source $DIR/VER.sh
# rm -rf /tmp/mariadb
# mkdir -p /tmp/mariadb
# cd /tmp/mariadb
# name=mariadb-$VER-ubuntu-$(echo $(lsb_release -rs | cut -d '.' -f 1,2 | tr '\n' '.' | sed 's/\.$//')).tgz
# wget -c https://github.com/i18n-ops/ops/releases/download/mariadb-$VER/$name
# tar -xvzf $name -C /usr/local/mariadb --strip-components=1
# rm -rf /usr/local/mariadb
# mkdir -p /usr/local/mariadb
# chown -R mariadb:mariadb /usr/local/mariadb
