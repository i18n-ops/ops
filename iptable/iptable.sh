#!/usr/bin/env bash

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
set -e

if [ -z "$3" ]; then
  echo "USAGE : $0 LOCAL_PORT MYSQL_HOST MARIADB_PORT"
  exit 1
else
  LOCAL_PORT=$1
  DST_HOST=$2
  DST_PORT=$3
fi

sed -i '/^net.ipv4.ip_forward/c\net.ipv4.ip_forward=1' /etc/sysctl.conf

PROTOCOL=${4:-"tcp"}

# 如果上面的命令没有找到net.ipv4.ip_forward，则在文件末尾添加
if ! grep -q '^net.ipv4.ip_forward' /etc/sysctl.conf; then
  echo 'net.ipv4.ip_forward=1' >>/etc/sysctl.conf
fi

sysctl -p

cat /proc/sys/net/ipv4/ip_forward

iptables -t nat -L --line-numbers

# protocol="tcp udp"

# 允许进来和已连接继续
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

rm_rule() {
  iptables -t nat -L $1 --line-numbers | grep " $2 dpt:$3 " | sort -n -r | while read num target prot opt source destination; do
    iptables -t nat -D $1 $num
  done
}

map() {
  local_host=$1
  local_port=$2

  #目标地址及端口
  dst_host=$3
  dst_port=$4

  protocol="$5"

  rm_rule tcp $LOCAL_PORT

  for i in $protocol; do
    rm_rule OUTPUT $i $local_port
    rm_rule PREROUTING $i $local_port
    rm_rule POSTROUTING $i $dst_port
    # 必须配置 OUTPUT
    iptables -t nat -A OUTPUT -p $i -d $local_host --dport $local_port -j DNAT --to $dst_host:$dst_port
    iptables -t nat -A PREROUTING -p $i -d $local_host --dport $local_port -j DNAT --to $dst_host:$dst_port
    iptables -t nat -A POSTROUTING -p $i -d $dst_host --dport $dst_port -j SNAT --to $local_host
  done
}

#必须用本机的外网ip,不能用127.0.0.1
LOCAL_HOST=$(ip -4 addr show eth0 | grep inet | awk '{print $2}' | cut -d/ -f1)

map $LOCAL_HOST $LOCAL_PORT $DST_HOST $DST_PORT "$PROTOCOL"
# map $LOCAL_HOST $LOCAL_PORT $DST_HOST $DST_PORT "tcp udp"

# 显示已有规则
iptables -t nat -L -n --line-number
