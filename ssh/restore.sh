#!/usr/bin/env bash

if [ -z "$3" ]; then
  echo "Usage: $0 hostname ip passwd"
  exit 1
else
  hostname=$1
  ip=$2
  export SSHPASS=$3
fi

direnv allow
DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

dist=../../dist
if [ ! -d "$dist" ]; then
  git -C ../.. clone --depth=1 git@github.com:i18n-dist/dist.git
fi

if ! command -v sshpass &>/dev/null; then
  case $(uname -s) in
  Linux*)
    apt install -y sshpass
    ;;
  Darwin*)
    brew install esolitos/ipa/sshpass
    ;;
  *)
    echo "need install sshpass"
    ;;
  esac
fi

root_ip=root@$ip

keyscan() {
  ssh-keygen -R $ip
  ssh-keyscan -H $ip >>~/.ssh/known_hosts
}

keyscan $ip

rsync="sshpass -e rsync --mkpath --progress -avz -e ssh"

id_ed25519=$dist/ssh/id_ed25519
chmod 600 $id_ed25519

ssh="sshpass -e ssh $root_ip"
$rsync --perms --chown=root $id_ed25519 $root_ip:/root/.ssh/

vpssrc=os/vps/$hostname/
if [ ! -d "$vpssrc" ]; then
  chmod 600 ${vpssrc}etc/ssh/*
  chmod 700 ${vpssrc}etc/ssh
  $rsync --perms --chown=root ./$vpssrc $root_ip:/
fi

$ssh "set -ex && apt-get update && apt-get install -y unzip direnv git && hostnamectl set-hostname $hostname && ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts && export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_ed25519' && cd /tmp && rm -rf os && git clone --depth=1 git@github.com:i18n-ops/os.git && mkdir -p /os && rsync --remove-source-files -av os/ /os/ && cd /os && ./init.sh && passwd -d root"
