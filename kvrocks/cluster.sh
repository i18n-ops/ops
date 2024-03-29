#!/usr/bin/env bash

set -ex

if ! command -v redis-cli &>/dev/null; then
  apt-get install -y redis-tools
fi

U1=0000000000000000000000000000000000000001
U1_IP=184.174.36.122

U2=0000000000000000000000000000000000000002
U2_IP=38.242.220.222

U3=0000000000000000000000000000000000000003
U3_IP=184.174.34.189

MAX_RANGE=16383

ALL_NODES_INFO="\
$U2 $U2_IP $R_PORT master - 0-$MAX_RANGE
$U1 $U1_IP $R_PORT slave $U2
$U3 $U3_IP $R_PORT slave $U2
"

VERSION=1

redis-cli -a $R_PASSWORD -h 127.0.0.1 -p $R_PORT CLUSTERX SETNODES "$ALL_NODES_INFO" $VERSION
