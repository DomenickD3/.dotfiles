# vim: ai ts=2 sw=2 et sts=2 ft=sh

# Command aliases
alias rmswp="find ./ -type f -name \"*.sw[aop]\" -delete"
alias old='cd $OLDPWD'
alias mytop='top -u $USER'
alias grep='grep --color=auto'
alias ls='ls -h --color=auto'
alias alert="echo -ne '\007'"
alias vd='vimdiff'

# force tmux to expect 256 colors
alias tmux='tmux -2'
alias tls='tmux ls'

# source dotfiles
alias sra='source ~/.bash_aliases'
alias srb='source ~/.bashrc'
alias srt='tmux source-file ~/.tmux.conf'

# edit dotfiles
alias arc='vim ~/.bash_aliases'
alias brc='vim ~/.bashrc'
alias trc='vim ~/.tmux.conf'
alias vrc='vim ~/.vimrc'
