# sc:complete 0 compgen -f -X '!*.cpp' -- "$COMP_CUR" ; compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc cpp loop [file.cpp]" 0 1 "$@"

MAKEFILE="$(pwd)/Makefile"
temp::file OUT

exec 3>&1

while :; do
  (
    export KEEP_COLOR="$LOG_COLOR" CXXFLAGS="${CXXFLAGS:-} -fdiagnostics-color=always"
    if [ "$#" -eq 0 ]; then
      "$SC" cpp makefile
      log::status "Making tests"
      make -s tests
    else
      "$SC" cpp run "$@"
    fi
  ) 3>&1 >"$OUT" 2>&1 </dev/null || true

  clear
  cat "$OUT"
  echo

  if [ -f "$MAKEFILE" ]; then
    sleep 3
  else
    log::debug "Polling for changes"
    "$SC" utils poll-change "$1"
  fi
done
