# sc:alias wcode
# sc:complete 0 compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc web codium [dir-or-file]" 0 1 "$@"
state::dir "web/codium" STATE_DIR

DIR_OR_FILE="$(realpath "${1:-$(pwd)}")"

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
  local target="$STATE_DIR/codium"
  "$SC" http download "$tarball" \
    "https://github.com/VSCodium/vscodium/releases/download/$version/vscodium-reh-web-linux-$(_codium_arch)-$version.tar.gz"
  rm -rf "$target"
  mkdir "$target"
  "$SC" archive extract "$tarball" "$target"
  rm "$tarball"
}

github::ensure "codium" "VSCodium/vscodium" "$STATE_DIR/codium.version" _install_codium

process::random_port "PORT"
process::random_token "TOKEN"

[ -f "$DIR_OR_FILE" ] && DIR_OR_FILE="$(dirname "$DIR_OR_FILE")"

log::info "Starting codium on port $PORT (folder: $DIR_OR_FILE)"

"$STATE_DIR/codium/bin/codium-server" \
  --port "$PORT" \
  --connection-token "$TOKEN" \
  --server-data-dir "$STATE_DIR/server-data" \
  --user-data-dir "$STATE_DIR/user-data" \
  --extensions-dir "$STATE_DIR/extensions" \
  >/dev/null 2>&1 &
codium_pid=$!

"$SC" web tunnel "$PORT" "?tkn=$TOKEN&folder=$DIR_OR_FILE" &
tunnel_pid=$!

process::wait_any_pid $codium_pid $tunnel_pid
