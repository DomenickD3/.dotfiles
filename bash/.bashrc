# vim: ai ts=2 sw=2 et sts=2 ft=sh

# If not running interactively, don't do anything.
case $- in
  *i*) ;;
  *) return ;;
esac

# Avoid duplicate history entries, append history, and keep a useful history size.
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Update LINES and COLUMNS after terminal or tmux pane resizes.
shopt -s checkwinsize

# Make less friendlier for compressed and non-text input files.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -x /usr/bin/dircolors ]; then
  # Load shell color definitions for ls from ~/.dircolors, or use the system defaults.
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

if [ -n "$BASH_VERSION" ]; then
  if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
  fi
fi

if [ -d "$HOME/.local/bin" ] ; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/.nix-profile/bin" ]; then
  export PATH="$HOME/.nix-profile/bin:$PATH"
fi

# Set a colored prompt: red user, yellow separators, cyan host, green working directory.
export PS1="\[\033[38;5;196m\]\u\[$(tput sgr0)\]\[\033[38;5;11m\]@\[$(tput sgr0)\]\[\033[38;5;14m\]\h\[$(tput sgr0)\]\[\033[38;5;11m\][\[$(tput sgr0)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]\[\033[38;5;11m\]]\\$\[$(tput sgr0)\]"

# Set xterm/rxvt window titles to user@host:dir.
case "$TERM" in
  xterm* | rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
esac

# Use groff's backspace formatting so less can recolor manpage styles.
export MANROFFOPT='-c'

# Prefer less' native color support; fall back to termcap overrides for older less.
if less --help 2>/dev/null | grep -q -- '--use-color'; then
  export LESS='--use-color -R -Dd+G -Dk+G -Dsy* -Dur_*' # raw ANSI colors, bold/blink green, standout yellow bold, underline red bold
else
  export LESS_TERMCAP_mb=$'\e[1;32m'   # blinking text: bright green
  export LESS_TERMCAP_md=$'\e[1;32m'   # bold text: bright green
  export LESS_TERMCAP_me=$'\e[0m'      # end bold/blink mode
  export LESS_TERMCAP_se=$'\e[0m'      # end standout mode
  export LESS_TERMCAP_so=$'\e[01;33m'  # standout text: bright yellow
  export LESS_TERMCAP_ue=$'\e[0m'      # end underline mode
  export LESS_TERMCAP_us=$'\e[1;4;31m' # underlined text: bright red underline
fi

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Uncomment to color GCC warnings and errors.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -d "$HOME/.bashrc.d" ]; then
  for bashrc_fragment in "$HOME"/.bashrc.d/*.bash; do
    [ -r "$bashrc_fragment" ] && . "$bashrc_fragment"
  done
  unset bashrc_fragment
fi

## Functions
rmswp() {
  find . -type f -name '*.sw[aop]' -delete
}

old() {
  cd "$OLDPWD" || return
}

dt() {
  git difftool HEAD $1
}
