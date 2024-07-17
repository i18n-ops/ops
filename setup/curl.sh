#!/usr/bin/env bash

if [ -z "$3" ]; then
  echo "USAGE : $0 org/project version"
  exit 1
else
  PROJECT=$1
  VER=$2
  NAME=$3
fi

set -ex

cd /root/i18n/conf

bash -c "git fetch --all && git reset --hard origin/main && git checkout main" &

case "$(uname -s)" in
"Darwin")
  OS="apple-darwin"
  ;;
"Linux")
  (ldd --version 2>&1 | grep -q musl) && clib=musl || clib=gun
  OS="unknown-linux-$clib"
  ;;
"MINGW*" | "CYGWIN*")
  OS="pc-windows-msvc"
  ;;
*)
  echo "Unsupported System"
  exit 1
  ;;
esac

ARCH=$(uname -m)

if [[ "$ARCH" == "arm64" || "$ARCH" == "arm" ]]; then
  ARCH="aarch64"
fi

TZT=$ARCH-$OS.tar.zst

echo $VER $TZT

TMP=/tmp/$PROJECT/$VER
rm -rf $TMP
mkdir -p $TMP
cd $TMP

set +x
if [ -z "$TZT_PASSWORD" ]; then
  DOWN=$TZT
else
  ENC=$TZT.enc
  DOWN=$ENC
fi
set -x

wget -q -c https://github.com/$PROJECT/releases/download/$VER/$DOWN

if ! [ -z "$ENC" ]; then
  set +x
  openssl enc -md sha512 -pbkdf2 -d -aes-256-cbc -in "$ENC" -out "$TZT" -pass pass:"$TZT_PASSWORD"
  set -x
  rm $ENC
fi

# 必须要 --no-same-owner , 不然会导致根目录权限错误, 进而导致重启无法登录 ssh ( Missing privilege separation directory: /run/sshd )
tar --no-same-owner -xvf $TZT
rm $TZT

if [ -f "init.sh" ]; then
  ./init.sh
  rm init.sh
fi

rsync --remove-source-files -av . /

systemctl daemon-reload

wait

systemctl enable --now $NAME
systemctl restart $NAME
systemctl status $NAME --no-pager
