source "$SC_LIBS"
core::init
process::require_args "$#" 1 1 "usage: sc cpp loop <file.cpp>"

FILE="$(realpath "$1")"
temp::file OUT

while :; do
  log::info "Running..." | log::trim
  "$SC" cpp run "$FILE" >"$OUT" 2>&1
  clear
  cat "$OUT"
  echo
  "$SC" utils poll-change "$FILE"
done
