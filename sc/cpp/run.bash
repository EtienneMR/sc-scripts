source "$SC_LIBS"
core::init
process::require COMPILER "clang++" "g++"
process::require_args "$#" 1 1 "usage: sc cpp run <file.cpp>"

FILE="$(realpath "$1")"
IN="${FILE%.cpp}.in"
COMPILE_COMMAND="$COMPILER -Wall -Wextra -fcolor-diagnostics"

temp::file BIN

log::debug "Resolving dependencies for $FILE"
mapfile -t DEPS < <("$SC" utils cpp-deps "$FILE") || log::die "dependency resolution failed"
log::debug "Dependencies: ${DEPS[*]}"

$COMPILE_COMMAND "${DEPS[@]}" "$FILE" -o "$BIN" >&2 || log::die "compilation failed"

RIN="$([ -f "$IN" ] && echo "$IN" || echo "/dev/null")"
"$BIN" <"$RIN"
