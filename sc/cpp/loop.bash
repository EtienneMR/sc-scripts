source "$SC_LIBS"
core::init
process::require_args "$#" 1 1 "Usage: sc cpp loop <file.cpp>"

FILE="$(realpath "$1")"
temp::file OUT

while :; do
  KEEP_COLOR=$LOG_COLOR "$SC" cpp run "$FILE" 3>&1 >"$OUT" 2>&1 || true
  clear
  cat "$OUT"
  echo
  log::debug "Polling for changes"
  "$SC" utils poll-change "$FILE"
done
