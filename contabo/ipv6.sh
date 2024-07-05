#!/usr/bin/env bash

set -ex

grep -q '^net.ipv6.ip_nonlocal_bind' /etc/sysctl.conf || echo 'net.ipv6.ip_nonlocal_bind=1' >>/etc/sysctl.conf
netplan generate && netplan apply

netcfg=/etc/netplan/01-netcfg.yaml
if [ -f "$netcfg" ]; then
  chmod 600 $netcfg
  sed -i "/net.ipv6.conf.all.disable_ipv6.*/d" /etc/sysctl.conf
  sysctl -q -p && echo 0 >/proc/sys/net/ipv6/conf/all/disable_ipv6
  sed -i "s/#//" $netcfg
  netplan generate && netplan apply
fi
