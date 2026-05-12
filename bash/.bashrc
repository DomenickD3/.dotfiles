# vim: ai ts=2 sw=2 et sts=2 ft=sh

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

# Set a colored prompt: red user, yellow separators, cyan host, green working directory.
export PS1="\[\033[38;5;196m\]\u\[$(tput sgr0)\]\[\033[38;5;11m\]@\[$(tput sgr0)\]\[\033[38;5;14m\]\h\[$(tput sgr0)\]\[\033[38;5;11m\][\[$(tput sgr0)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]\[\033[38;5;11m\]]\\$\[$(tput sgr0)\]"

# Use groff's backspace formatting so less can recolor manpage styles.
export MANROFFOPT='-c'

# Prefer less' native color support; fall back to termcap overrides for older less.
if less --help 2>/dev/null | grep -q -- '--use-color'; then
  export LESS='--use-color -Dd+G -Dk+G -Dsy* -Dur_*' # bold/blink green, standout yellow bold, underline red bold
else
  export LESS_TERMCAP_mb=$'\e[1;32m'   # blinking text: bright green
  export LESS_TERMCAP_md=$'\e[1;32m'   # bold text: bright green
  export LESS_TERMCAP_me=$'\e[0m'      # end bold/blink mode
  export LESS_TERMCAP_se=$'\e[0m'      # end standout mode
  export LESS_TERMCAP_so=$'\e[01;33m'  # standout text: bright yellow
  export LESS_TERMCAP_ue=$'\e[0m'      # end underline mode
  export LESS_TERMCAP_us=$'\e[1;4;31m' # underlined text: bright red underline
fi

## Functions
dt() {
  git difftool HEAD $1
}
