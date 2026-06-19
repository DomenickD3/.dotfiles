# .dotfiles

Personal Linux/WSL dotfiles for shell, Git, tmux, Vim, and Neovim.

## Overview

This repository stores my terminal and editor configuration files.

| Area | Path | Purpose |
|---|---|---|
| Bash | `bash/` | Shell config, aliases, prompt, PATH setup, helper functions |
| Git | `git/.config/git/` | Global Git ignore rules |
| tmux | `tmux/` | Terminal multiplexer config, prefix/binds, window/pane behavior |
| Neovim | `nvim/.config/nvim/` | Lua-based Neovim configuration |
| Vim | `vim/` | Vim configuration |

## Structure

```text
.
├── bash/
│   ├── .bashrc
│   ├── .bash_aliases
│   ├── .bashrc.d/
│   └── .dircolors
├── git/
│   └── .config/git/ignore
├── nvim/
│   └── .config/nvim/
├── tmux/
│   └── .tmux.conf
├── vim/
└── .gitignore
```

## Bash

The Bash config includes:

- Interactive-shell guard
- History settings
- `less` / manpage color support
- Custom colored prompt
- Local PATH additions
- Bash completion loading
- Optional fragment loading from `~/.bashrc.d/*.bash`
- Helper functions like `rmswp`, `old`, and `dt`

Common aliases include:

```bash
tls   # tmux ls
sra   # source ~/.bash_aliases
srb   # source ~/.bashrc
srt   # tmux source-file ~/.tmux.conf

arc   # edit ~/.bash_aliases
brc   # edit ~/.bashrc
nvrc  # edit ~/.config/nvim/init.lua
trc   # edit ~/.tmux.conf
vrc   # edit ~/.vimrc
```

## tmux

The tmux config includes:

- `C-a` prefix instead of default `C-b`
- Window indexing starting at `1`
- Automatic window renumbering
- Reload binding
- Vim-style pane movement
- Pane resizing binds
- Custom split-window binds that preserve the current path
- Custom status bar
- Window swap/move helpers

Notable binds:

| Bind | Action |
|---|---|
| `Prefix + r` | Reload tmux config |
| `Prefix + m` | Move/swap current window to a target index |
| `Alt + Left` | Swap current window left and follow it |
| `Alt + Right` | Swap current window right and follow it |
| `Prefix + h/j/k/l` | Move between panes |
| `Prefix + C-h/C-j/C-k/C-l` | Resize panes |
| `Prefix + -` | Split pane vertically |
| `Prefix + \` | Split pane horizontally |
| `Prefix + c` | New window in current pane path |
| `Prefix + B` | Confirm and kill session |

## Neovim

The Neovim config is Lua-based and loaded from:

```text
nvim/.config/nvim/init.lua
```

It uses `lazy.nvim` for plugin management and includes:

- Telescope
- Treesitter
- Undotree
- Fugitive
- Mason / mason-lspconfig / nvim-lspconfig
- nvim-cmp
- LuaSnip

Leader key:

```vim
,
```

Common mappings:

| Mapping | Action |
|---|---|
| `,pv` | Open netrw file explorer |
| `,ff` | Telescope find files |
| `,fc` | Telescope Git files |
| `,fg` | Telescope live grep |
| `,fh` | Telescope help tags |
| `,u` | Toggle Undotree |
| `,f` | Format with active LSP |
| `,y` / `,Y` | Yank to system clipboard |
| `,d` | Delete to black-hole register |
| `,x` | Make current file executable |

## Installation

This repo is intended to be installed with GNU Stow.

Stow treats each top-level directory in this repo as a separate “package” and creates symlinks from that package into the target home directory.

## Requirements

- `bash`
- `stow`

### Expected location

Clone the repo to:

```text
~/.dotfiles
```

Example:

```bash
git clone git@github.com:DomenickD3/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

If you do not pass any package names, the installer discovers every top-level package directory and installs the non-empty ones.

### How Stow links files

From inside `~/.dotfiles`, each top-level directory can be stowed into `$HOME`:

```bash
stow -R bash --target="$HOME"
stow -R git --target="$HOME"
stow -R tmux --target="$HOME"
stow -R nvim --target="$HOME"
stow -R vim --target="$HOME"
```

Given this repo structure:

```text
~/.dotfiles/
├── bash/
│   ├── .bashrc
│   └── .bash_aliases
├── git/
│   └── .config/git/ignore
├── tmux/
│   └── .tmux.conf
├── nvim/
│   └── .config/nvim/
└── vim/
    └── .vimrc
```

Stow creates symlinks in `$HOME` that point back into `~/.dotfiles`:

```text
~/.bashrc        -> ~/.dotfiles/bash/.bashrc
~/.bash_aliases -> ~/.dotfiles/bash/.bash_aliases
~/.config/git   -> ~/.dotfiles/git/.config/git
~/.tmux.conf    -> ~/.dotfiles/tmux/.tmux.conf
~/.config/nvim  -> ~/.dotfiles/nvim/.config/nvim
~/.vimrc        -> ~/.dotfiles/vim/.vimrc
```

The `-R` flag means “restow”:

```bash
stow -R bash --target="$HOME"
```

This removes and recreates the symlinks for that package, which is useful after adding, removing, or moving files inside a dotfile package.

To remove symlinks for a package:

```bash
stow -D bash --target="$HOME"
```

### Install Specific Packages

```bash
./install.sh bash git tmux vim nvim
```

### Preview Changes

Use a dry run to see what Stow would change without modifying your home directory:

```bash
./install.sh --dry-run
```

### Conflicts and Backups

The installer checks each selected Stow package before running `stow`. If an
existing target path would conflict with a managed dotfile, the installer moves
that path into a timestamped backup directory before creating the symlink.

The default backup location is:

```text
~/.dotfiles-backups/YYYYMMDD-HHMMSS/
```

For example, if `~/.bashrc` conflicts during installation, it is moved to a path
like:

```text
~/.dotfiles-backups/20260611-203000/home/ragnar/.bashrc
```

Backups preserve the absolute target path underneath the backup directory. This
makes it possible to restore either one file or a whole config directory without
guessing where it came from.

To inspect the most recent backup:

```bash
latest_backup="$(find ~/.dotfiles-backups -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
find "$latest_backup" \( -type f -o -type l \)
```

To restore one backed-up file, copy it from the backup path to its original
location:

```bash
cp "$latest_backup/home/$USER/.bashrc" ~/.bashrc
```

To restore a backed-up directory, copy it recursively:

```bash
cp -a "$latest_backup/home/$USER/.config/nvim" ~/.config/nvim
```

If you need to keep the backup somewhere else, pass an explicit backup
directory:

```bash
./install.sh --backup-dir ~/tmp/dotfiles-backups
```

If you want conflicting files removed instead of backed up, use `--force`. Only
use this when you are certain the conflicting files are disposable:

```bash
./install.sh --force
```

### Help

```bash
./install.sh --help
```

## Notes

These dotfiles are personal and optimized for my workflow. They are public for reference, but should be reviewed before being used directly on another machine.

Before installing, check for existing files:

```bash
ls -la ~/.bashrc ~/.bash_aliases ~/.tmux.conf ~/.vimrc ~/.config/nvim
```

Back up anything important before replacing it.

## License

Personal configuration files. Use at your own risk.
