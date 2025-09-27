#!/usr/bin/env bash

[ "$UID" -eq 0 ] || exec sudo "$0" "$@"
set -ex

NAME=proxy_http

if ! command -v $NAME &>/dev/null; then
  cargo install $NAME
fi

cat <<EOF > "/etc/systemd/system/${NAME}.service"
[Unit]
Description=$NAME
After=network.target

[Service]
ExecStart=bash -c 'set -a && . /etc/proxy_http/env && RUST_LOG=info && set +a && exec /opt/rust/bin/proxy_http -b 0.0.0.0:\$PROXY_PORT'
Restart=on-failure
RestartSec=10
Environment="PATH=/usr/bin"

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now $NAME
systemctl restart $NAME
