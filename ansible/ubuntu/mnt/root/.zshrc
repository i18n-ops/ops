. ~/.bash_aliases

setopt +o nomatch

[ -z "$PS1" ] && return

. ~/.zinit.zsh

eval "$(mise activate zsh)"

autoload -Uz compinit && compinit -u

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
setopt extended_glob

eval "$(atuin init zsh --disable-up-arrow)"
