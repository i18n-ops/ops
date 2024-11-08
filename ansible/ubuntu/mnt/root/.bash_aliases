. /etc/profile

alias df=duf
alias du=diskus
alias gl=glances
alias ls=eza
alias vi=nvim
alias vim=nvim
alias rg="rg -L"

export EDITOR=nvim
export TERM=xterm-256color

export PATH="$HOME/.bin:$BUN_INSTALL/bin:$HOME/.yarn/bin:$PATH"

if [ -f ~/.export ]; then
. ~/.export
fi
