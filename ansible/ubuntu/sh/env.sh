if [ -z "$CURL" ]; then
  curl -s -o /dev/null -I --connect-timeout 3 -m 4 -s https://x.com || (
    GFW=1 &&
      GITHUB_PROXY=https://ghp.ci/ &&
      git config --global \
        url."${GITHUB_PROXY}https://github.com/".insteadOf \
        "https://github.com/" &&
      rsync -avz gfw/ /
  )

  CURL="curl --connect-timeout 5 --max-time 10 --retry 9 --retry-delay 0 -sSf"

  cargo_install() {
    cargo install --root /usr/local $@
  }

  cargo_install_github() {
    cargo_install --git ${GITHUB_PROXY}https://github.com/$@
  }

  . /etc/profile
fi
