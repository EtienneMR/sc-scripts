state::dir() {
  local d="${XDG_STATE_HOME:-$HOME/.local/state}/sc/$SC_SCRIPT"
  log::debug "Created state dir $d"
  make -p "$d"
  printf -v "$1" '%s' "$d"
}
