# vim: ai ts=2 sw=2 et sts=2 ft=sh

if [ -f "$HOME/.temp_aliases" ]; then
  . "$HOME/.temp_aliases"
fi

download_song() {
  local yt_dlp_bin

  if [ "$#" -ne 1 ]; then
    printf 'usage: download_song SONG\n' >&2
    return 2
  fi

  if command -v yt-dlp >/dev/null 2>&1; then
    yt_dlp_bin="yt-dlp"
  elif command -v yt-dlp_linux >/dev/null 2>&1; then
    yt_dlp_bin="yt-dlp_linux"
  else
    printf 'download_song: yt-dlp is not installed\n' >&2
    return 1
  fi

  "$yt_dlp_bin" --no-playlist -f 'ba[ext=m4a]' \
    --paths "home:$HOME/Music/iTunes/iTunes Media/Automatically Add to iTunes" \
    --paths "temp:$HOME/Music/.yt-dlp-temp" \
    -- "$1"
}

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

alias upgrade_codex="nix profile upgrade codex --extra-experimental-features 'nix-command flakes'"

# Open Codex with the short code command.
alias code='codex'
