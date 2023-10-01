# vim: ai ts=2 sw=2 et sts=2 ft=sh

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bash_aliases" ]; then
      . "$HOME/.bash_aliases"
    fi

    if [ -f "$HOME/.temp_aliases" ]; then
      . "$HOME/.temp_aliases"
    fi
fi

export PS1="\[\033[38;5;196m\]\u\[$(tput sgr0)\]\[\033[38;5;11m\]@\[$(tput sgr0)\]\[\033[38;5;14m\]\h\[$(tput sgr0)\]\[\033[38;5;11m\][\[$(tput sgr0)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]\[\033[38;5;11m\]]\\$\[$(tput sgr0)\]"
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

## Functions
dt() {
  git difftool HEAD $1
}

## TMUX --
# swap window
tsw() {
  tmux swap-window -s "$1" -t "$2"
}

# kill session by name
tks() {
  tmux kill-session -t "$1"
}

# attach to session
txa() {
  tmux a -t "$1"
}

# update-windows - remove empty tmux (i.e. fix tmux window numbering)
tuw() {
  i=1
  tmux list-windows | cut -d: -f1 | while read window_index; do
  if ((window_index !=i)); then
    tmux move-window -d -s $window_index -t $i
  fi
  ((i++))
done
}

# move to front (moves tmux window to index 1)
mtf() {
  tuw
  window_index=$(tmux display-message -p '#I')
  first_index=$(tmux list-windows | cut -d: -f1 | head -n 1)
  for ((i=$window_index; i > $first_index; --i)); do
    tmux swap-window -t -1
  done
}

# move to back (moves tmux window to last index)
mtb() {
  tuw
  window_index=$(tmux display-message -p '#I')
  last_index=$(tmux list-windows | cut -d: -f1 | tail -n 1)
  for ((i=$window_index; i<$last_index; ++i)); do
    tmux swap-window -t +1
  done
}

# move in front (moves tmux window in front of $1)
mif() {
  window_index=$(tmux display-message -p '#I')
  for ((i=$window_index; i > $1; --i)); do
    tmux swap-window -t -1
  done
}

# move in back (moves tmux window in back of $1)
mib() {
  window_index=$(tmux display-message -p '#I')
  for ((i=$window_index; i < $1; ++i)); do
    tmux swap-window -t +1
  done
}
## -- TMUX
