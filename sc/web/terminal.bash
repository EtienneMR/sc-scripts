# sc:alias wterm
source "$SC_LIBS"
core::init
process::usage "sc web terminal [command]" 0 1 "$@"
state::dir "web/terminal" STATE_DIR

TERMINAL_COMMAND="${1:-${SHELL:-bash}}"

_ttyd_arch() {
  case "$(uname -m)" in
    x86_64) echo "x86_64" ;;
    aarch64) echo "aarch64" ;;
    armv7l) echo "armhf" ;;
    *) log::die "Unsupported architecture for ttyd: $(uname -m)" ;;
  esac
}

_install_ttyd() {
  local version="$1"
  "$SC" http download "$STATE_DIR/ttyd" \
    "https://github.com/tsl0922/ttyd/releases/download/$version/ttyd.$(_ttyd_arch)"
  chmod +x "$STATE_DIR/ttyd"
}

github::ensure "ttyd" "tsl0922/ttyd" "$STATE_DIR/ttyd.version" _install_ttyd

process::random_port "PORT"
process::random_token "TOKEN"

log::info "Starting terminal on port $PORT (shell: $TERMINAL_COMMAND)"

"$STATE_DIR/ttyd" \
  --port "$PORT" \
  --writable \
  --base-path "/$TOKEN" \
  "$TERMINAL_COMMAND" >/dev/null 2>&1 &
ttyd_pid=$!

"$SC" web tunnel "$PORT" "/$TOKEN" &
tunnel_pid=$!

process::wait_any_pid $ttyd_pid $tunnel_pid
