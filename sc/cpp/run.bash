# sc:complete 0 compgen -f -X '!*.cpp' -- "$COMP_CUR" ; compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc cpp run <file.cpp>" 1 1 "$@"
process::require COMPILER "clang++" "g++"

log::debug "Opening fd 3"
2>/dev/null >&3 || exec 3>&1

FILE="$(realpath "$1")"
MAKEFILE="$(pwd)/Makefile"

if [ -f "$MAKEFILE" ]; then
  KEEP_COLOR=$LOG_COLOR "$SC" cpp makefile "$FILE" 3>&1 | log::overwrite >&3

  RELATIVE="dist/$(basename "${FILE%.cpp}")"
  BIN="$(pwd)/$RELATIVE"

  log::info "Making binary" | log::overwrite >&3

  make "$RELATIVE" >/dev/null
else
  COMPILE_COMMAND="$COMPILER -Wall -Wextra -fcolor-diagnostics"

  temp::file BIN

  log::info "Resolving dependencies" | log::overwrite >&3
  log::debug "Resolving dependencies for $FILE"
  mapfile -t DEPS < <("$SC" utils cpp-deps "$FILE") || log::die "Dependency resolution failed"
  log::debug "Dependencies: ${DEPS[*]}"

  log::info "Compiling $((${#DEPS[@]} + 1)) files" | log::overwrite >&3
  $COMPILE_COMMAND "${DEPS[@]}" "$FILE" -o "$BIN" >&2 || log::die "Compilation failed"
fi

IN="${FILE%.cpp}.in"
[ -f "$IN" ] || IN="/dev/null"

log::info "Running entrypoint" | log::overwrite >&3
echo >&3

"$BIN" <"$IN" || log::die "Execution failed (return code $?)"
