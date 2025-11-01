if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

[ -z "$PS1" ] && return

if command -v mise &>/dev/null; then
  eval "$(mise activate --quiet bash)"
fi

if [ -f ~/.tmux_default ]; then
. ~/.tmux_default > /dev/null 2>&1
fi

