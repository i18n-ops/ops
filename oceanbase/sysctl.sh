#!/usr/bin/env bash
set -ex
update_sysctl_conf() {
  local key=$1
  local value=$2
  local file="/etc/sysctl.conf"

  # 删除原有行（如果存在）
  sed -i "/^$key/d" $file

  # 追加新行
  echo "$key = $value" >>$file
}

# 定义更新 /etc/security/limits.conf 文件的函数
update_limits_conf() {
  local key=$1
  local value=$2
  local file="/etc/security/limits.conf"

  # 删除原有行（如果存在）
  sed -i "/^\* $key/d" $file

  # 追加新行
  echo "* $key $value" >>$file
}

update_sysctl_conf "fs.aio-max-nr" "1048576"
update_sysctl_conf "net.ipv4.tcp_rmem" "4097 98304 131070"
update_sysctl_conf "net.ipv4.tcp_wmem" "4097 98304 131070"
update_sysctl_conf "net.core.rmem_max" "16777216"
update_sysctl_conf "net.core.wmem_max" "16777216"
update_sysctl_conf "net.ipv4.tcp_slow_start_after_idle" "0"
update_sysctl_conf "net.ipv4.conf.default.rp_filter" "1"
update_sysctl_conf "net.ipv4.conf.default.accept_source_route" "0"
update_sysctl_conf "vm.max_map_count" "1000000"
update_sysctl_conf "fs.pipe-user-pages-soft" "0"
update_sysctl_conf "net.ipv4.ip_local_port_range" "3500 65535"

update_limits_conf "soft core" "unlimited"
update_limits_conf "hard core" "unlimited"
update_limits_conf "soft nofile" "655360"
update_limits_conf "hard nofile" "655360"
update_limits_conf "soft stack" "unlimited"
update_limits_conf "hard stack" "unlimited"

sysctl -p
