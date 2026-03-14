system::reboot_required() {
  [ -f /run/reboot-required ] && return 0

  if process::exists pacman; then
    local installed running
    installed="$(pacman -Q linux 2>/dev/null | awk '{print $2}' | sed 's/-/./g')"
    running="$(uname -r | sed 's/-/./g')"
    [ -n "$installed" ] && [[ $running != "$installed"* ]] && return 0
  fi
  return 1
}
