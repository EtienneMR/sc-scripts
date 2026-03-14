source "$SC_LIBS"
core::init
process::require_args "$#" 0 0 "Usage: sc web-codium"
state::dir "web-codium" STATE_DIR

_codium_arch() {
  case "$(uname -m)" in
    x86_64) echo "x64" ;;
    aarch64) echo "arm64" ;;
    armv7l) echo "armhf" ;;
    *) log::die "Unsupported architecture for codium: $(uname -m)" ;;
  esac
}

_install_codium() {
  local version="$1"
  local tarball="$STATE_DIR/codium.tar.gz"
  http::download "$tarball" \
    "https://github.com/VSCodium/vscodium/releases/download/$version/vscodium-reh-web-linux-$(_codium_arch)-$version.tar.gz"
  rm -rf "$STATE_DIR/codium"
  mkdir "$STATE_DIR/codium"
  tar -xzf "$tarball" -C "$STATE_DIR/codium"
  rm "$tarball"
}

github::ensure "codium" "VSCodium/vscodium" "$STATE_DIR/codium.version" _install_codium

process::random_port "PORT"
TOKEN="$(tr -dc 'a-zA-Z0-9' </dev/urandom 2>/dev/null | head -c 16 || true)"

"$STATE_DIR/codium/bin/codium-server" \
  --port "$PORT" \
  --connection-token "$TOKEN" \
  --server-data-dir "$STATE_DIR/server-data" \
  --user-data-dir "$STATE_DIR/user-data" \
  --extensions-dir "$STATE_DIR/extensions" \
  >/dev/null 2>&1 &
codium_pid=$!

"$SC" tunnel "$PORT" "?tkn=$TOKEN&folder=$(pwd -P)" &
tunnel_pid=$!

process::wait_any_pid $codium_pid $tunnel_pid
