if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

eval "$(mise activate --quiet bash)"

[ -z "$PS1" ] && return

if [ -f ~/.tmux_default ]; then
. ~/.tmux_default > /dev/null 2>&1
fi

