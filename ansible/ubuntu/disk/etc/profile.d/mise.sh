export MISE_DATA_DIR=/opt/mise
export MISE_CACHE_DIR=/cache/mise

if command -v mise &>/dev/null; then
  eval $(mise env)
fi
