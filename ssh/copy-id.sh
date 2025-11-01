#!/usr/bin/env bash

cout() {
  echo -e "\033[32m$1\033[0m"
}

cerr() {
  echo -e "\033[31m$1\033[0m"
}

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

if [ -z "$PASSWORD" ]; then
  cout "环境变量 PASSWORD 未设置\nEnvironment variable PASSWORD is not set"
  exit 1
fi

if [ -z "$IP" ]; then
  cout "环境变量 IP 未设置\nEnvironment variable IP is not set"
  exit 1
fi

if [ -z "$LOGIN" ]; then
  LOGIN=root
  USER_HOME=/root
  cout "登录用户: $LOGIN\nLOGIN USER: $LOGIN"
else
  USER_HOME=/home/$LOGIN
fi

cpid() {
  # 通过主机名获取 IP
  ip=$(ssh -G $1 | grep 'hostname ' | head -n 1 | awk '{print $2}')
  ssh-keygen -R $ip
  ssh-keyscan -H $ip >>~/.ssh/known_hosts
  cout "正在将 SSH 公钥复制到 $ip\nCopying SSH public key to $ip"
  sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no $LOGIN@$ip
  if [ $? -eq 0 ]; then
    cout "成功将 SSH 公钥复制到 $ip\nSuccessfully copied SSH public key to $ip"
  else
    cerr "将 SSH 公钥复制到 $ip 失败\nFailed to copy SSH public key to $ip"
  fi
}

for ip in $IP; do
  cpid $ip &
done
wait

if [ -z "$SSH_KEY" ]; then
  SSH_KEY=$HOME/.ssh/id_ed25519
fi

cpkey() {
  ip=$1
  uip=$LOGIN@$ip
  cout "正在将 $SSH_KEY 复制到 $uip\nCopying $SSH_KEY key to $uip"
  scp $SSH_KEY.pub $SSH_KEY $uip:$USER_HOME/.ssh/
  ssh $uip "chmod 700 $USER_HOME/.ssh; chmod 600 $USER_HOME/.ssh/*; chmod 644 $USER_HOME/.ssh/*.pub"
}

if [ -f "$SSH_KEY" ]; then
  for ip in $IP; do
    cpkey $ip &
  done
  wait
fi
