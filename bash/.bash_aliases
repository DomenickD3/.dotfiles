# vim: ai ts=2 sw=2 et sts=2 ft=sh

if [ -f "$HOME/.temp_aliases" ]; then
  . "$HOME/.temp_aliases"
fi

# Command aliases
alias grep='grep --color=auto'
alias ls='ls -h --color=auto'
alias nvimdiff='nvim -d'
alias vd='nvim -d'
alias tmux='tmux -2' # force tmux to expect 256 colors
alias tls='tmux ls' # list tmux sessions

# source dotfiles
alias sra='. ~/.bash_aliases'
alias srb='. ~/.bashrc'
alias srt='tmux source-file ~/.tmux.conf'

# edit dotfiles
alias arc='nvim ~/.bash_aliases'
alias brc='nvim ~/.bashrc'
alias nvrc='nvim ~/.config/nvim/init.lua'
alias trc='nvim ~/.tmux.conf'
alias vrc='nvim ~/.vimrc'
