#!/usr/bin/env bash

set -ex

if grep -q "net.ipv6.ip_nonlocal_bind" /etc/sysctl.conf; then
  sed -i '/^net.ipv6.ip_nonlocal_bind/c\net.ipv6.ip_nonlocal_bind=1' /etc/sysctl.conf
else
  echo -e '\nnet.ipv6.ip_nonlocal_bind=1\n' | tee -a /etc/sysctl.conf
fi

sysctl -p

add_route=/usr/lib/networkd-dispatcher/routable.d/50-add-route
ipv6=$(ip -6 addr show dev eth0 | grep "inet6.*scope global" | awk '{print $2}' | awk -F'/' '{print $1}' | awk -F':' '{print $1":"$2":"$3":"$4"::"}')

if [ ! -f "$add_route" ]; then

  if ! command -v networkd-dispatcher &>/dev/null; then
    apt install -y networkd-dispatcher
  fi


  cat <<EOF >$add_route
#!/bin/sh

if [ "\$IFACE" = "eth0" ]; then
    ip route add local $ipv6/64 dev eth0
fi
EOF
  chmod +x $add_route

fi

systemctl enable --now networkd-dispatcher || true
systemctl restart networkd-dispatcher || true

# netcup 需要这个 ， contabo 不需要这个
if curl --interface ${ipv6}f  -IsS --max-time 10 https://baidu.com >/dev/null 2>&1; then
  echo "不需要 ndppd"
else
  apt-get install -y ndppd
  cat <<EOF >/etc/ndppd.conf
route-ttl 30000
proxy eth0 {
  router no
  timeout 500
  ttl 30000
  rule $ipv6/64 {
    static
  }
}
EOF
  systemctl enable --now ndppd || true
  systemctl restart ndppd || true
fi
