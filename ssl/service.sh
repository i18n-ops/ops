#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Usage: $0 <script_path> / 用法: $0 <脚本路径>"
  exit 1
fi

fp="$1"

if [ ! -f "$fp" ] || [ ! -x "$fp" ]; then
  echo "Error: The provided script path is invalid or not executable / 错误：提供的脚本路径无效或不可执行"
  exit 1
fi

service_name="ssl_update.service"

cat <<EOF >/etc/systemd/system/$service_name
[Unit]
Description=Run SSL update script (SSL 更新脚本)
After=network.target

[Service]
Type=oneshot
ExecStart=$fp
User=root

[Install]
WantedBy=multi-user.target
EOF

weekly_name="ssl_update.timer"

cat <<EOF >/etc/systemd/system/$weekly_name
[Unit]
Description=Trigger ssl_update weekly ( 每周触发 ssl_update )

[Timer]
OnCalendar=weekly
Persistent=true
Unit=$service_name

[Install]
WantedBy=weeklys.target
EOF

systemctl daemon-reload

systemctl enable --now $weekly_name
