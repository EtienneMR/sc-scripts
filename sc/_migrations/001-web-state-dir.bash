source "$SC_LIBS"
core::init

OLD_CODIUM_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sc/web-codium"
OLD_TUNNEL_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sc/tunnel"
NEW_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/sc/web"

if [ -d "$OLD_CODIUM_DIR" ]; then
  mkdir -p "$NEW_DIR"
  mv "$OLD_CODIUM_DIR" "$NEW_DIR"
  log::success "Migrated web codium state dir"
fi

if [ -d "$OLD_TUNNEL_DIR" ]; then
  mkdir -p "$NEW_DIR"
  mv "$OLD_TUNNEL_DIR" "$NEW_DIR"
  log::success "Migrated web tunnel state dir"
fi
