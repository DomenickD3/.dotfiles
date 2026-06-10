#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [options] [package...]

Install this repository's dotfiles with GNU Stow.

Options:
  -n, --dry-run             Show what would change without modifying anything
  -f, --force               Remove conflicting files instead of backing them up
      --backup-dir DIR      Store backups in DIR
  -h, --help                Show this help text

If no packages are provided, every top-level package directory is installed.

Environment:
  DOTFILES_SKIP_NIX_PROFILE=1  Skip installing this repo's Nix profile package.
EOF
}

log() {
  printf '%s\n' "$*"
}

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    log "[dry-run] $*"
    return 0
  fi

  "$@"
}

backup_target() {
  local target="$1"
  local target_rel

  if [ "$FORCE" -eq 1 ]; then
    run rm -rf "$target"
    return 0
  fi

  if [ -z "$BACKUP_DIR_CREATED" ]; then
    run mkdir -p "$BACKUP_DIR"
    BACKUP_DIR_CREATED=1
  fi

  target_rel="${target#/}"
  run mkdir -p "$BACKUP_DIR/$(dirname "$target_rel")"
  run mv "$target" "$BACKUP_DIR/$target_rel"
}

link_points_to() {
  local link="$1"
  local expected="$2"

  [ -L "$link" ] || return 1
  path_points_to "$link" "$expected"
}

path_points_to() {
  local path="$1"
  local expected="$2"
  local actual
  local expected_actual

  [ -e "$path" ] || return 1

  actual="$(readlink -f "$path" 2>/dev/null || true)"
  expected_actual="$(readlink -f "$expected" 2>/dev/null || true)"

  [ -n "$actual" ] && [ "$actual" = "$expected_actual" ]
}

normalize_owned_link() {
  local source="$1"
  local target="$2"
  local relative_source

  link_points_to "$target" "$source" || return 0

  relative_source="$(realpath --relative-to="$(dirname "$target")" "$source")"
  if [ "$(readlink "$target")" = "$relative_source" ]; then
    return 0
  fi

  log "normalize: $target"
  run rm "$target"
  run ln -s "$relative_source" "$target"
}

normalize_owned_links() {
  local package="$1"
  local entry
  local source
  local target

  while IFS= read -r entry; do
    source="$REPO_ROOT/$package/$entry"
    target="$HOME/$entry"
    normalize_owned_link "$source" "$target"
  done < <(cd "$REPO_ROOT/$package" && find . -mindepth 1 | sed 's#^\./##' | sort)
}

entry_installed() {
  local source="$1"
  local target="$2"
  local child

  if path_points_to "$target" "$source"; then
    return 0
  fi

  if [ -d "$source" ] && [ -d "$target" ] && [ ! -L "$target" ]; then
    while IFS= read -r child; do
      entry_installed "$source/$child" "$target/$child" || return 1
    done < <(find "$source" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort)
    return 0
  fi

  return 1
}

package_installed() {
  local package="$1"
  local entry
  local source
  local target

  while IFS= read -r entry; do
    source="$REPO_ROOT/$package/$entry"
    target="$HOME/$entry"
    entry_installed "$source" "$target" || return 1
  done < <(cd "$REPO_ROOT/$package" && find . -mindepth 1 -maxdepth 1 | sed 's#^\./##' | sort)
}

prepare_target() {
  local package="$1"
  local entry="$2"
  local source="$REPO_ROOT/$package/$entry"
  local target="$HOME/$entry"

  if link_points_to "$target" "$source"; then
    return 0
  fi

  if [ -d "$source" ] && [ -d "$target" ] && [ ! -L "$target" ]; then
    return 0
  fi

  if [ -L "$target" ] || [ -e "$target" ]; then
    log "conflict: $target"
    backup_target "$target"
  fi

  if [ -d "$source" ]; then
    run mkdir -p "$target"
  fi
}

install_package() {
  local package="$1"
  local stow_args=(-v -t "$HOME")
  local entry

  if [ ! -d "$REPO_ROOT/$package" ]; then
    log "warning: missing package, skipping: $package"
    return 0
  fi

  if ! find "$REPO_ROOT/$package" -mindepth 1 -print -quit | grep -q .; then
    log "skip: empty package: $package"
    return 0
  fi

  if package_installed "$package"; then
    log "stow: $package already installed"
    return 0
  fi

  normalize_owned_links "$package"

  while IFS= read -r entry; do
    prepare_target "$package" "$entry"
  done < <(cd "$REPO_ROOT/$package" && find . -mindepth 1 -maxdepth 1 | sed 's#^\./##' | sort)

  if [ "$DRY_RUN" -eq 1 ]; then
    stow_args=(-n "${stow_args[@]}")
  fi

  log "stow: $package"
  run stow "${stow_args[@]}" "$package"
}

package_selected() {
  local wanted="$1"
  local package

  for package in "${PACKAGES[@]}"; do
    if [ "$package" = "$wanted" ]; then
      return 0
    fi
  done

  return 1
}

install_nix_profile() {
  local profile_ref="path:$REPO_ROOT#default"

  if [ "${DOTFILES_SKIP_NIX_PROFILE:-0}" = 1 ]; then
    log "nix profile: skipped by DOTFILES_SKIP_NIX_PROFILE=1"
    return 0
  fi

  if [ ! -f "$REPO_ROOT/flake.nix" ]; then
    return 0
  fi

  if ! command -v nix >/dev/null 2>&1; then
    log "warning: nix not found; skipping Nix profile packages"
    return 0
  fi

  if nix --extra-experimental-features nix-command \
    --extra-experimental-features flakes \
    profile list | grep -F "Original flake URL: path:$REPO_ROOT" >/dev/null 2>&1; then
    log "nix profile: already installed: $profile_ref"
    return 0
  fi

  log "nix profile: $profile_ref"
  run nix --extra-experimental-features nix-command \
    --extra-experimental-features flakes \
    profile add --priority 20 "$profile_ref"
}

install_neovim_dependencies() {
  local nix_packages=()

  if command -v tree-sitter >/dev/null 2>&1 && command -v cc >/dev/null 2>&1; then
    return 0
  fi

  if ! command -v nix >/dev/null 2>&1; then
    log "warning: install tree-sitter and gcc/cc for nvim-treesitter parser builds"
    return 0
  fi

  if ! command -v tree-sitter >/dev/null 2>&1; then
    nix_packages+=("nixpkgs#tree-sitter")
  fi

  if ! command -v cc >/dev/null 2>&1; then
    nix_packages+=("nixpkgs#gcc")
  fi

  if [ "${#nix_packages[@]}" -gt 0 ]; then
    log "nix: install Neovim Treesitter build dependencies"
    run nix \
      --extra-experimental-features nix-command \
      --extra-experimental-features flakes \
      profile add "${nix_packages[@]}"
    hash -r
  fi
}

build_neovim_treesitter_parsers() {
  if ! command -v nvim >/dev/null 2>&1; then
    log "warning: nvim not found; skipping Treesitter parser build"
    return 0
  fi

  log "nvim: build Treesitter parsers"
  run nvim --headless "+Lazy build nvim-treesitter" "+qa"
}

DRY_RUN=0
FORCE=0
BACKUP_DIR="${HOME}/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR_CREATED=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      ;;
    -f|--force)
      FORCE=1
      ;;
    --backup-dir)
      shift
      if [ "$#" -eq 0 ]; then
        log "error: --backup-dir requires a directory path"
        exit 1
      fi
      BACKUP_DIR="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      log "error: unknown option: $1"
      usage
      exit 1
      ;;
    *)
      break
      ;;
  esac
  shift
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_nix_profile

if ! command -v stow >/dev/null 2>&1; then
  log "error: GNU Stow is required but was not found in PATH"
  exit 1
fi

PACKAGES=("$@")

if [ "${#PACKAGES[@]}" -eq 0 ]; then
  while IFS= read -r package; do
    PACKAGES+=("$package")
  done < <(
    cd "$REPO_ROOT" &&
      find . -mindepth 1 -maxdepth 1 -type d \
        ! -name '.*' \
        ! -name '.git' \
        | sed 's#^\./##' | sort
  )
fi

if [ "${#PACKAGES[@]}" -eq 0 ]; then
  log "error: no stow packages found"
  exit 1
fi

cd "$REPO_ROOT"

for package in "${PACKAGES[@]}"; do
  install_package "$package"
done

if package_selected nvim; then
  install_neovim_dependencies
  build_neovim_treesitter_parsers
fi

if [ "$DRY_RUN" -eq 1 ]; then
  log "dry run complete"
elif [ "$FORCE" -eq 1 ]; then
  log "installation complete"
elif [ -n "$BACKUP_DIR_CREATED" ]; then
  log "installation complete; backups stored in $BACKUP_DIR"
else
  log "installation complete; no backups were needed"
fi
