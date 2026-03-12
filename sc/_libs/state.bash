state::dir() {
  local d="${XDG_STATE_HOME:-$HOME/.local/state}/sc/$SC_SCRIPT"
  [ -d "$d" ] && log::debug "found state dir $d" || log::debug "created state dir $d"
  mkdir -p "$d"
  printf -v "$1" '%s' "$d"
}
