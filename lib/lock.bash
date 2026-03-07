LOCK_DIR="${XDG_RUNTIME_DIR:-/tmp}/scripts"
LOCK_FILE="$LOCK_DIR/$SCRIPT_NAME.lock"

lock::acquire() {
    mkdir -p $LOCK_DIR

    exec 200>"$LOCK_FILE"
    flock -n 200 || log::die "Another instance is already running (lock: $LOCK_FILE)"

    log::debug "Acquired lock $LOCK_FILE"
    LOCK_FD=200
}

lock::release() {
    if [[ -n "${LOCK_FD:-}" ]]; then
        flock -u "$LOCK_FD"
        rm -f "$LOCK_FILE"
        log::debug "Released lock $LOCK_FILE"
    fi
}
