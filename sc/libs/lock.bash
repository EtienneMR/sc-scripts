LOCK_DIR="${XDG_RUNTIME_DIR:-/tmp}/sc"
LOCK_FILE="$LOCK_DIR/$SC_SCRIPT.lock"

lock::acquire() {
  mkdir -p $LOCK_DIR

  exec 200>"$LOCK_FILE"
  flock -n 200 || log::die "another instance is already running (lock: $LOCK_FILE)"

  log::debug "acquired lock $LOCK_FILE"
  LOCK_FD=200
}

lock::release() {
  if [[ -n "${LOCK_FD:-}" ]]; then
    flock -u "$LOCK_FD"
    rm -f "$LOCK_FILE"
    log::debug "released lock $LOCK_FILE"
  fi
}
