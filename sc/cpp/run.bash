# sc:complete 0 compgen -f -X '!*.cpp' -- "$COMP_CUR" ; compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc cpp run <file.cpp>" 1 1 "$@"
process::require COMPILER "clang++" "g++"

FILE="$(realpath "$1")"
MAKEFILE="$(pwd)/Makefile"

if [ -f "$MAKEFILE" ]; then
  "$SC" cpp makefile "$FILE"

  BIN="dist/$(realpath --relative-to=. "${FILE%.*}")"

  log::status "Making binary"
  make "$BIN" >/dev/null
else
  COMPILE_COMMAND="$COMPILER -Wall -Wextra ${CXXFLAGS:-}"

  temp::file BIN

  log::status "Resolving dependencies"
  log::debug "Resolving dependencies for $FILE"
  mapfile -t DEPS < <("$SC" utils cpp-deps "$FILE") || log::die "Dependency resolution failed"
  log::debug "Dependencies: ${DEPS[*]}"

  log::status "Compiling $((${#DEPS[@]} + 1)) file(s)"
  $COMPILE_COMMAND "${DEPS[@]}" "$FILE" -o "$BIN" >&2 || log::die "Compilation failed"
fi

IN="${FILE%.cpp}.in"
[ -f "$IN" ] || IN="/dev/stdin"

log::status "Running"

"$BIN" <"$IN" || log::die "Execution failed (return code $?)"
