TEMP_DIRS=()

temp::dir() {
    local d
    d="$(mktemp -d 2>/dev/null || mktemp -d -t tmp)"
    TEMP_DIRS+=("$d")
    printf "%s\n" "$d"
}

temp::file() {
    local f
    f="$(mktemp 2>/dev/null || mktemp -t tmp)"
    TEMP_DIRS+=("$f")
    printf "%s\n" "$f"
}

temp::cleanup() {
    for d in "${TEMP_DIRS[@]:-}"; do
        [ -e "$d" ] && log::debug "Removing temp dir $d" && rm -rf "$d"
    done
    TEMP_DIRS=()
}
