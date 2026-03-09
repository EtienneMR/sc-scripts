source "$SC_LIBS"
core::init

temp::dir LOGS_DIR
state::dir STATE_DIR

PORT=$((1025 + RANDOM % (65535 - 1025 + 1)))
TOKEN="$(tr -dc 'a-zA-Z0-9' </dev/urandom | head -c 16 || true)"

if [ ! -f "$STATE_DIR/cloudflared" ]; then
  log::info "Downloading cloudflared"
  http::download "$STATE_DIR/cloudflared" https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
  chmod +x "$STATE_DIR/cloudflared"
fi

if [ ! -d "$STATE_DIR/codium" ]; then
  if [ ! -f "$STATE_DIR/codium.tar.gz" ]; then
    log::info "Downloading codium"
    http::download "$STATE_DIR/codium.tar.gz" https://github.com/VSCodium/vscodium/releases/download/1.110.01571/vscodium-reh-web-linux-x64-1.110.01571.tar.gz
  fi

  log::info "Extracting codium"
  mkdir codium
  tar -xzf"$STATE_DIR/codium.tar.gz" -C "$STATE_DIR/codium"
fi

log::debug "Writting logs to $LOGS_DIR"

"$STATE_DIR/cloudflared" tunnel --url "http://localhost:$PORT" >"$LOGS_DIR/cloudflared.log" 2>&1 &
pid1=$!

"$STATE_DIR/codium/bin/codium-server" --port "$PORT" --connection-token "$TOKEN" >"$LOGS_DIR/codium.log" 2>&1 &
pid2=$!

log::info "Waiting for tunnel" | log::trim
HOST=""
while [ -z "$HOST" ]; do
  sleep 1
  HOST="$(grep -oaPm 1 'https://[A-Za-z0-9._-]+\.trycloudflare\.com' "$LOGS_DIR/cloudflared.log" || true)"
  printf "."
done
printf "\n"
log::success "Tunnel ready at $HOST?tkn=$TOKEN&folder=$(pwd -P)"

wait -n $pid1 $pid2
kill $pid1 $pid2
wait $pid1 $pid2
