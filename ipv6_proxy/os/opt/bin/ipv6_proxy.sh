#!/usr/bin/env bash

USER=root
set -o allexport
RUST_LOG=debug,supervisor=warn,hyper=warn,rustls=warn,h2=warn,tower=warn,reqwest=warn,h3=warn,quinn_udp=warn,quinn_proto=warn,watchexec=warn,globset=warn,hickory_proto=warn,hickory_resolver=warn
RUST_BACKTRACE=short
. $USER/i18n/conf/env/ipv6_proxy.sh
set +o allexport

set -ex

ipv6=$(ip -6 addr show dev eth0 | grep "inet6.*scope global" | awk '{print $2}' | sed 's/::1\//::\//')

exec /opt/bin/ipv6_proxy -b 0.0.0.0:$IPV6_PROXY_PORT -i $ipv6
