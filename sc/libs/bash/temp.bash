TEMP_DIRS=()

temp::dir() {
    local d
    d="$(mktemp -d --suffix=.sc)"
    TEMP_DIRS+=("$d")
    log::debug "Created temp dir $d"
    printf -v "$1" '%s' "$d"
}

temp::file() {
    local d
    d="$(mktemp --suffix=.sc)"
    TEMP_DIRS+=("$d")
    log::debug "Created temp file $d"
    printf -v "$1" '%s' "$d"
}

temp::cleanup() {
    for d in "${TEMP_DIRS[@]:-}"; do
        [ -e "$d" ] && log::debug "Removing temp dir $d" && rm -rf "$d"
    done
    TEMP_DIRS=()
}
