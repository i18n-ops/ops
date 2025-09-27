#!/usr/bin/env bash

DIR=$(dirname $(realpath "$0"))
cd $DIR

. /etc/ops/chasquid/conf.sh
. /etc/ops/chasquid/forword.sh

if [ ! -d "node_modules" ]; then
  bun i
fi

if [ ! $SMTP_ROOT_HOST ]; then
  echo "MISS ENV SMTP_ROOT_HOST"
  exit 1
fi
if [ ! $FORWORD_TO ]; then
  echo "MISS ENV FORWORD_TO"
  exit 1
fi

ETC_CONF=/etc/chasquid
CONF=$(dirname $DIR)/conf

set -ex

if ! [ -x "$(command -v chasquid)" ]; then
  if [ -d "$ETC_CONF" ]; then
    rm -rf $ETC_CONF.bak
    mv $ETC_CONF $ETC_CONF.bak
  fi

  rm -rf /etc/systemd/system/chasquid* /tmp/chasquid
  cd /tmp
  LATEST_VERSION=$(curl -s https://api.github.com/repos/albertito/chasquid/tags | jq -r '.[0].name')
  git clone -b $LATEST_VERSION --depth=1 https://github.com/albertito/chasquid.git
  cd chasquid

  make
  make install-binaries
  make install-config-skeleton

  # 确保系统服务会被安装
  if [ -d "${ETC_CONF}.bak" ]; then
    rm -rf $ETC_CONF
    mv $ETC_CONF.bak $ETC_CONF
  fi

  systemctl daemon-reload
  cd $DIR
fi

if ! [ -x "$(command -v setfacl)" ]; then
  apt-get install -y acl
fi

user=mail
id -u $user || useradd -s /bin/false $user
getent group $user >/dev/null || groupadd $user
getent group ssl >/dev/null || groupadd ssl
usermod -a -G ssl $user

for i in dkimsign dkimverify dkimkeygen; do
  if ! [ -x "$(command -v $i)" ]; then
    go install github.com/driusan/dkim/cmd/$i@latest
  fi
done

cert=$ETC_CONF/certs/$SMTP_ROOT_HOST
mkdir -p $cert || true
cd $cert
private=dkim_privkey.pem
if [ ! -f "$private" ]; then
  dkimkeygen
  mv private.pem $private
fi

link() {
  if [ ! -e "$2" ]; then
    ln -s /opt/ssl/${SMTP_ROOT_HOST}_ecc/$1 $2
  fi
}
link fullchain.cer fullchain.pem
link $SMTP_ROOT_HOST.key privkey.pem

cd $ETC_CONF

d=domains/$SMTP_ROOT_HOST

mkdir -p $d
cd $d

if [ ! -f "aliases" ]; then
  echo -e "i: $FORWORD_TO\n*: $FORWORD_TO" >aliases
fi

if [ ! -f "dkim_selector" ]; then
  dkim=$(node -e "console.log(($(($(date +%s) / 86400))).toString(36))")
  echo $dkim >dkim_selector
else
  dkim=$(cat dkim_selector)
fi

# rsync --ignore-existing -av $DIR/conf/ $ETC_CONF
# rsync --ignore-existing -av $DIR/domains/ $ETC_CONF/domains/$SMTP_ROOT_HOST
chgrp -R $user $ETC_CONF

mkdir -p /var/lib/chasquid
chown $user:$user /var/lib/chasquid

systemctl enable chasquid --now
systemctl restart chasquid
systemctl status chasquid --no-pager

set +x
green() {
  echo -e "\033[32m$1\033[0m"
}

$DIR/cron.sh

chasquid-util user-add $SMTP_USER --password=$SMTP_PASSWORD

echo -e "\nDKIM → Please Add DNS TXT : $(green $dkim._domainkey.$SMTP_ROOT_HOST)\n"
cat $cert/dns.txt
echo ''
