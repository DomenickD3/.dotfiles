# vim: ai ts=2 sw=2 et sts=2 ft=sh

start_nix_daemon() {
  if [ -n "${WSL_DISTRO_NAME:-}" ] && command -v wsl.exe >/dev/null 2>&1; then
    wsl.exe -d "$WSL_DISTRO_NAME" -u root service nix-daemon status >/dev/null 2>&1 ||
      wsl.exe -d "$WSL_DISTRO_NAME" -u root service nix-daemon start >/dev/null 2>&1
    return
  fi

  if [ -d /run/systemd/system ] && command -v systemctl >/dev/null 2>&1; then
    systemctl is-active --quiet nix-daemon.service ||
      sudo -n systemctl start nix-daemon.service >/dev/null 2>&1
  fi
}
start_nix_daemon
unset -f start_nix_daemon
