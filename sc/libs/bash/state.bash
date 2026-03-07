STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sc/$SC_SCRIPT"

state::make() {
    log::debug "Making state dir $STATE_DIR"
    mkdir -p "$STATE_DIR"
}

state::cd() {
    state::make
    cd "$STATE_DIR"
}
