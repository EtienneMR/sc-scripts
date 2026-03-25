source "$SC_LIBS"
core::init
process::usage "sc cpp loop <file.cpp>" 1 1 "$@"

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
