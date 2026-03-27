source "$SC_LIBS"
core::init
process::usage "sc system status [-q]" 0 1 "$@"
state::dir "system" STATE_DIR

QUIET=0
[ "${1:-}" = "-q" ] && QUIET=1

_full_update() {
  local file="$STATE_DIR/updated"
  local days msg

  if [ ! -f "$file" ]; then
    [ "$QUIET" -eq 0 ] && log::warn "System has never been updated using sc"
    return
  fi

  days=$((($(date +%s) - $(stat -c %Y "$file")) / 86400))
  msg="System last updated ${days}d ago"

  if [ "$days" -ge 14 ]; then
    log::error "$msg — run: sc system update"
  elif [ "$days" -ge 7 ]; then
    log::warn "$msg — run: sc system update"
  elif [ "$QUIET" -eq 1 ]; then
    :
  elif [ "$days" -ge 2 ]; then
    log::info "$msg"
  else
    log::success "$msg"
  fi
}

_package_update() {
  if [ "$QUIET" -eq 0 ] && process::exists checkupdates; then
    if checkupdates >/dev/null; then
      log::info "Package updates available"
    else
      log::success "All packages up to date"
    fi
  fi
}

_reboot_required() {
  system::reboot_required && log::warn "System reboot required" || true
}

_full_update
_package_update
_reboot_required
