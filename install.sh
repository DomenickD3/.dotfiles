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

prepare_target() {
  local package="$1"
  local entry="$2"
  local source="$REPO_ROOT/$package/$entry"
  local target="$HOME/$entry"

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    return 0
  fi

  if [ -L "$target" ] || [ -e "$target" ]; then
    log "conflict: $target"
    backup_target "$target"
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

  while IFS= read -r entry; do
    prepare_target "$package" "$entry"
  done < <(cd "$REPO_ROOT/$package" && find . -mindepth 1 | sed 's#^\./##' | sort)

  if [ "$DRY_RUN" -eq 1 ]; then
    stow_args=(-n "${stow_args[@]}")
  fi

  log "stow: $package"
  run stow "${stow_args[@]}" "$package"
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

if [ "$DRY_RUN" -eq 1 ]; then
  log "dry run complete"
elif [ "$FORCE" -eq 1 ]; then
  log "installation complete"
elif [ -n "$BACKUP_DIR_CREATED" ]; then
  log "installation complete; backups stored in $BACKUP_DIR"
else
  log "installation complete; no backups were needed"
fi
