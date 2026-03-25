source "$SC_LIBS"
core::init
process::usage "sc cpp run <file.cpp>" 1 1 "$@"
process::require COMPILER "clang++" "g++"

log::debug "Opening fd 3"
2>/dev/null >&3 || exec 3>&1

FILE="$(realpath "$1")"
COMPILE_COMMAND="$COMPILER -Wall -Wextra -fcolor-diagnostics"

IN="${FILE%.cpp}.in"
[ -f "$IN" ] || IN="/dev/null"

temp::file BIN

log::info "Resolving dependencies" | log::overwrite >&3
log::debug "Resolving dependencies for $FILE"
mapfile -t DEPS < <("$SC" utils cpp-deps "$FILE") || log::die "Dependency resolution failed"
log::debug "Dependencies: ${DEPS[*]}"

log::info "Compiling $((${#DEPS[@]} + 1)) files" | log::overwrite >&3
$COMPILE_COMMAND "${DEPS[@]}" "$FILE" -o "$BIN" >&2 || log::die "Compilation failed"

log::info "Running entrypoint" | log::overwrite >&3
"$BIN" <"$IN" || log::die "Execution failed (return code $?)"
