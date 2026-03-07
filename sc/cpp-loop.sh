source "$("$SC" libs bash)"
core::init
process::require "clang++"

DIR=""
temp::dir DIR
BIN="$DIR/bin"
OUT="$DIR/out"
IN="$1.in"
COMPILE_COMMAND="clang++ -Wall -Wextra"

while :
do
    log::info "Compiling " | log::trim
    rm -f "$BIN"
    $COMPILE_COMMAND "$1" -o "$BIN" > "$OUT" 2>&1 || true
    if [ -f "$BIN" ]
    then
        printf "Running "
        RIN="$([ -f "$IN" ] && echo "$IN" || echo "/dev/null")"
        "$BIN" >> "$OUT" 2>&1 < "$RIN" || true
    fi
    clear
    cat "$OUT"
    echo
    sc utils poll_change "$1"
done
