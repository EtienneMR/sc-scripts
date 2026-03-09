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

process::require_args() {
  local count="$1" min="$2" max="$3" usage="$4"
  if [ "$count" -lt "$min" ]; then
    echo "error: expected at least $min arguments, got $#" >&2
    echo "$usage" >&2
    exit 1
  fi
  if [ "$count" -gt "$max" ]; then
    echo "error: expected at most $max arguments, got $#" >&2
    echo "$usage" >&2
    exit 1
  fi
}

process::random_port() {
  local _var="$1"
  local _port _attempts=0

  while [ $_attempts -lt 10 ]; do
    _port=$((1025 + RANDOM % (65535 - 1025 + 1)))
    if ! _process::port_in_use "$_port"; then
      log::debug "found free random port $_port"
      printf -v "$_var" '%s' "$_port"
      return 0
    fi
    _attempts=$((_attempts + 1))
    log::debug "port $_port in use, retrying"
  done

  log::die "could not find a free port after 10 attempts"
}

_process::port_in_use() {
  local port="$1"
  if process::exists ss; then
    ss -tlnH "sport = :$port" | grep -q .
  elif process::exists nc; then
    nc -z localhost "$port" 2>/dev/null
  else
    log::warn "could not check port usage: process::random_port requires ss or nc to check port usage"
  fi
}

process::wait_output() {
  local file="$1"
  local pattern="$2"
  local _var="$3"
  local timeout="${4:-10}"

  local match="" elapsed=0

  while [ -z "$match" ]; do
    if [ "$elapsed" -ge "$timeout" ]; then
      log::die "timed out after ${elapsed}s waiting for pattern in $file"
    fi
    sleep 1
    elapsed=$((elapsed + 1))
    match="$(grep -oaPm 1 "$pattern" "$file" 2>/dev/null || true)"
  done

  printf -v "$_var" '%s' "$match"
}

process::wait_any_pid() {
  wait -n "$@"
  kill "$@" 2>/dev/null || true
  wait "$@" 2>/dev/null || true
}
