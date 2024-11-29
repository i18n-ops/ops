#!/usr/bin/env bash

set -ex

if grep -q "net.ipv6.ip_nonlocal_bind" /etc/sysctl.conf; then
  sed -i '/^net.ipv6.ip_nonlocal_bind/c\net.ipv6.ip_nonlocal_bind=1' /etc/sysctl.conf
else
  echo -e '\nnet.ipv6.ip_nonlocal_bind=1\n' | tee -a /etc/sysctl.conf
fi

sysctl -p

add_route=/usr/lib/networkd-dispatcher/routable.d/50-add-route

if [ ! -f "$add_route" ]; then

  if ! command -v networkd-dispatcher &>/dev/null; then
    apt install -y networkd-dispatcher
  fi

  ipv6=$(ip -6 addr show dev eth0 | grep "inet6.*scope global" | awk '{print $2}' | sed 's/::1\//::\//')

  cat <<EOF >$add_route
#!/bin/sh

if [ "\$IFACE" = "eth0" ]; then
    ip route add local $ipv6 dev eth0
fi
EOF

  chmod +x $add_route
fi

systemctl enable --now networkd-dispatcher || true
systemctl restart networkd-dispatcher
