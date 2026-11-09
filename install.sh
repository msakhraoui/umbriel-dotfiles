#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

NO_PACKAGES=0
NO_PLUGINS=0
ASSUME_YES=0

PACKAGES=(
  kitty fastfetch grim slurp wl-clipboard brightnessctl
  fuzzel fish git neovim thunar
  noctalia-git umbriel-nightly
)

PLUGINS=(
  h465855hgg/lyrics
  noctalia/notes
  shangshui0302/github-kanban
  ycf/mawaqit
  thepunkoff/pomodoro
  cleboost/hotspot
  aabidk20/yt-music
  tranzem/media-lyrics
)

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
err() {
  printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<EOF
Usage: ./install.sh [options]

  --no-packages   skip repo setup and dnf install
  --no-plugins    skip Noctalia plugins and wallpaper
  -y, --yes       do not ask for confirmation
  -h, --help      show this help

Existing configs are moved to ~/.dotfiles-backup/<timestamp>/
EOF
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
    --no-packages) NO_PACKAGES=1 ;;
    --no-plugins) NO_PLUGINS=1 ;;
    -y | --yes) ASSUME_YES=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      usage
      err "unknown option: $1"
      ;;
    esac
    shift
  done
}

check_env() {
  [ "$EUID" -ne 0 ] || err "do not run as root"
  [ -f /etc/os-release ] || err "cannot detect the OS"
  # shellcheck disable=SC1091
  . /etc/os-release
  [ "${ID:-}" = "fedora" ] || err "Fedora only (detected: ${PRETTY_NAME:-unknown})"
  command -v dnf >/dev/null || err "dnf not found"
  command -v sudo >/dev/null || err "sudo not found"
  [ -d "$REPO_DIR/config" ] || err "config/ not found in $REPO_DIR"
}

confirm() {
  [ "$ASSUME_YES" -eq 1 ] && return 0
  echo "This will:"
  if [ "$NO_PACKAGES" -eq 0 ]; then
    echo "  - enable the third-party COPR lionheartp/Hyprland and the Terra repo"
  fi
  echo "  - replace your kitty, nvim, fuzzel, fastfetch, Thunar, umbriel and noctalia configs"
  echo "  - keep backups in $BACKUP_DIR"
  read -rp "Continue? [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]] || err "aborted"
}

install_packages() {
  log "Enabling repos"
  sudo dnf install -y 'dnf-command(copr)'
  sudo dnf copr enable -y lionheartp/Hyprland
  if ! rpm -q terra-release >/dev/null 2>&1; then
    sudo dnf install -y --nogpgcheck \
      --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
  fi

  log "Installing packages"
  sudo dnf install -y "${PACKAGES[@]}"
}

backup() {
  local target="$1"
  [ -e "$target" ] || [ -L "$target" ] || return 0
  mkdir -p "$BACKUP_DIR"
  mv "$target" "$BACKUP_DIR/${target//\//_}"
  warn "backed up $target"
}

install_dir() {
  local src="$REPO_DIR/$1" dst="$2"
  [ -d "$src" ] || {
    warn "missing $1, skipped"
    return 0
  }
  backup "$dst"
  mkdir -p "$dst"
  cp -a "$src"/. "$dst"/
  log "installed $dst"
}

install_file() {
  local src="$REPO_DIR/$1" dst="$2"
  [ -f "$src" ] || {
    warn "missing $1, skipped"
    return 0
  }
  backup "$dst"
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  log "installed $dst"
}

install_configs() {
  install_dir config/umbriel "$HOME/.config/umbriel"
  install_dir config/kitty "$HOME/.config/kitty"
  install_dir config/fastfetch "$HOME/.config/fastfetch"
  install_dir config/fish "$HOME/.config/fish"
  install_dir config/nvim "$HOME/.config/nvim"
  install_dir config/fuzzel "$HOME/.config/fuzzel"
  install_dir config/Thunar "$HOME/.config/Thunar"
  install_file config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml \
    "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml"
}

install_noctalia() {
  local dst="$HOME/.local/state/noctalia/settings.toml"
  install_file config/noctalia/settings.toml "$dst"
  if [ -f "$dst" ]; then
    sed -i "s|__HOME__|$HOME|g" "$dst"
  fi
  noctalia msg config-reload 2>/dev/null || true
}

install_wallpapers() {
  log "Copying wallpapers"
  mkdir -p "$HOME/Pictures/Wallpapers"
  cp --update=none "$REPO_DIR"/pictures/wallpapers/* "$HOME/Pictures/Wallpapers/"
}

enable_plugins() {
  command -v noctalia >/dev/null || {
    warn "noctalia not found, skipping plugins"
    return 0
  }
  log "Enabling Noctalia plugins"
  local p
  for p in "${PLUGINS[@]}"; do
    noctalia msg plugins enable "$p" || warn "failed: $p"
  done
  noctalia msg wallpaper-set "$HOME/Pictures/Wallpapers/arms.jpg" ||
    warn "Noctalia not running, set the wallpaper manually"
}

main() {
  parse_args "$@"
  check_env
  confirm

  if [ "$NO_PACKAGES" -eq 0 ]; then
    install_packages
  fi
  install_configs
  install_noctalia
  install_wallpapers
  if [ "$NO_PLUGINS" -eq 0 ]; then
    enable_plugins
  fi

  log "Done. Log out and back in."
  if [ -d "$BACKUP_DIR" ]; then
    log "Backups: $BACKUP_DIR"
  fi
}

main "$@"
