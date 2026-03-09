process::exists() {
  command -v "$1" >/dev/null 2>&1
}

process::require() {
  for cmd in "$@"; do
    process::exists "$cmd" || log::die "missing dependency: $cmd"
  done
}

process::detect_shell() {
  basename "${SHELL:-sh}"
}
