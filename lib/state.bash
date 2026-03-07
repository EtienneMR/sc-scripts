STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sc-scripts/$SCRIPT_NAME"

state::make() {
    mkdir -p "$STATE_DIR"
}

state::cd() {
    state::make
    cd "$STATE_DIR"
}
