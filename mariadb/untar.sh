#!/usr/bin/env bash

set -ex
cd /tmp/mariadb-*

groupadd mysql || true
useradd -r -g mysql -M -N -s /bin/false mysql || true
rm -rf /usr/local/mysql
mkdir -p /usr/local/mysql
tar -xvzf mariadb-*-*-*.tar.gz -C /usr/local/mysql --strip-components=1
chown -R mysql:mysql /usr/local/mysql
