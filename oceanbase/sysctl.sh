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

update_limits_conf "soft core" "unlimited"
update_limits_conf "hard core" "unlimited"
update_limits_conf "soft stack" "unlimited"
update_limits_conf "hard stack" "unlimited"

sysctl -p
