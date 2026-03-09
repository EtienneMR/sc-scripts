source "$SC_LIBS"
core::init
process::require_args "$#" 1 2 "usage: sc tunnel <port> [path]"
state::dir STATE_DIR

TUNNEL_PORT="$1"
TUNNEL_PATH="${2:-/}"

_cloudflared_arch() {
  case "$(uname -m)" in
    x86_64) echo "amd64" ;;
    aarch64) echo "arm64" ;;
    armv7l | armv6l) echo "arm" ;;
    i386 | i686) echo "386" ;;
    *) log::die "unsupported architecture for cloudflared: $(uname -m)" ;;
  esac
}

_install_cloudflared() {
  local version="$1"
  http::download "$STATE_DIR/cloudflared" "https://github.com/cloudflare/cloudflared/releases/download/$version/cloudflared-linux-$(_cloudflared_arch)"
  chmod +x "$STATE_DIR/cloudflared"
}

github::ensure "cloudflared" "cloudflare/cloudflared" "$STATE_DIR/cloudflared.version" _install_cloudflared

temp::dir LOGS_DIR
"$STATE_DIR/cloudflared" tunnel --url "http://localhost:$TUNNEL_PORT" >"$LOGS_DIR/cloudflared.log" 2>&1 &
tunnel_pid=$!

log::info "waiting for tunnel"
process::wait_output "$LOGS_DIR/cloudflared.log" "https://[A-Za-z0-9._-]+\.trycloudflare\.com" HOST

log::success "tunnel ready at: $HOST$TUNNEL_PATH"

wait $tunnel_pid
