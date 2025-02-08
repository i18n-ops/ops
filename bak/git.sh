#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if [ -d git ]; then
  cd git
  git pull origin main -f || true
  cd ..
else
  git clone --depth 1 ssh://git@ssh.github.com:443/i18n-bak/git.git
fi

GITDIR=$DIR/git

bak() {
  to=$GITDIR/$1/$(dirname $(dirname $2))
  mkdir -p $to
  cp $2 $to/
}

fd_bak() {
  set +x
  fd .git/config --no-ignore | while read -r fp; do
    # 检查文件中是否包含 i18n 相关的配置
    if grep -q 'i18n' "$fp"; then
      echo $fp
      bak $1 $fp
    fi
  done
  set -x
}

cd ../..
fd_bak i18n

cd ../demo/i18n
fd_bak demo

cd $GITDIR
git add .
git commit -m.
git push
