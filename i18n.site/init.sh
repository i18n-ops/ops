#!/usr/bin/env bash

set -ex

curl --connect-timeout 2 -m 4 -s https://x.com >/dev/null || GFW=1

if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
  eval $(~/.local/bin/mise env)
fi

initrc() {
  local file=$1
  local content=$2
  if [[ -f "$file" ]]; then
    if ! grep -q "^[[:space:]]*[^#].*mise activate" "$file"; then
      echo -e "\n$content" >>"$file"
    fi
  fi
}

initrc ~/.bashrc 'eval "$(~/.local/bin/mise activate bash)"'
initrc ~/.zshrc 'eval "$(~/.local/bin/mise activate zsh)"'
initrc ~/.config/fish/config.fish '~/.local/bin/mise activate fish | source'

if [ -n "$GFW" ]; then
  GITSITE=https://github.com/i18n-site
else
  GITSITE=https://atomgit.com/i18n
fi

gitclone() {
  local repo="${2:-$1}"
  if [ ! -d "$2" ]; then
    git clone --depth=1 $GITSITE/$1.git $repo
  else
    git -C $repo pull
  fi
}

if [ ! -d "site" ]; then
  mkdir -p i18n
  cd i18n
fi

gitclone site &
gitclone i18n.site.demo.docker docker &
gitclone demo.i18n.site md &
gitclone 18x &
wait

cd site
mise trust
mise exec -- echo init

cd ../18x
mise trust
bun i
./build.sh

bash <(curl -sS https://i.i18n.site) i18n.site
cd ../md
i18n.site
