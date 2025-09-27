#!/usr/bin/env bash

if [ -z "$CURL" ]; then
  curl -s -o /dev/null -I --connect-timeout 3 -m 4 -s https://x.com || export GFW=1

  if [ -n "$GFW" ]; then
    # GITHUB_PROXY=https://ghp.ci/
    # git config --global \
    #   url."${GITHUB_PROXY}https://github.com/".insteadOf \
    #   "https://github.com/"
    rsync --chown=root:root -av gfw/ /
    if [ -f "$HOME/.cargo/config.toml" ]; then
      sed -i 's/# \(replace-with = '\''rsproxy'\''\)/\1/' ~/.cargo/config.toml
    fi

  fi

  export CURL="curl --connect-timeout 5 --max-time 10 --retry 9 --retry-delay 0 -sSf"

  . /etc/profile

  if [[ ":$PATH:" != *":/opt/rust/bin:"* ]]; then
    export PATH="/opt/rust/bin:${PATH}"
  fi

  cargo_install() {
    cargo install --locked --root /usr/local $@
  }
  export -f cargo_install

  cargo_install_github() {
    cargo_install --git ${GITHUB_PROXY}https://github.com/$@
  }
  export -f cargo_install_github

fi
