source "$SC_LIBS"
core::init
state::dir "system" STATE_DIR

QUIET=0
[ "${1:-}" = "-q" ] && QUIET=1

_update_warn() {
  local file="$STATE_DIR/updated"
  local days msg

  if [ ! -f "$file" ]; then
    [ "$QUIET" -eq 0 ] && log::warn "System has never been updated using sc" || true
    return
  fi

  days=$((($(date +%s) - $(stat -c %Y "$file")) / 86400))
  msg="System last updated ${days}d ago"

  if [ "$days" -ge 14 ]; then
    log::error "$msg — run: sc system upgrade"
  elif [ "$days" -ge 7 ]; then
    log::warn "$msg — run: sc system upgrade"
  elif [ "$QUIET" -eq 1 ]; then
    :
  elif [ "$days" -ge 2 ]; then
    log::info "$msg"
  else
    log::success "$msg"
  fi
}

_update_warn
