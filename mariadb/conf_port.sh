#!/usr/bin/env bash

conf_port() {
  sed -i "/^port\s*=\s*/c\\port=$MYSQL_PORT" /etc/mysql/$1.cnf
}

conf_port conf.d/mariadb
conf_port mariadb
