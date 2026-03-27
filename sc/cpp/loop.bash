# sc:complete 0 compgen -f -X '!*.cpp' -- "$COMP_CUR" ; compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc cpp loop <file.cpp>" 1 1 "$@"

FILE="$(realpath "$1")"
MAKEFILE="$(pwd)/Makefile"
temp::file OUT

while :; do
  KEEP_COLOR=$LOG_COLOR "$SC" cpp run "$FILE" 3>&1 >"$OUT" 2>&1 || true
  clear
  cat "$OUT"
  echo
  log::debug "Polling for changes"

  if [ -f "$MAKEFILE" ]; then
    sleep 3
  else
    "$SC" utils poll-change "$FILE"
  fi
done
