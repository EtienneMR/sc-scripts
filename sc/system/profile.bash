source "$SC_LIBS"
core::init
process::usage "sc system profile" 0 0 "$@"

cat <<'EOF'
mkcd() { mkdir -p "$@" && cd "$_"; }
mkt() { cd "$(mktemp -d)" && pwd; }
cdl() { cd "$1" && ls -lA; }
EOF

echo -n "export EDITOR="
if process::exists codium; then
  echo '"codium --wait"'
elif process::exists code; then
  echo '"code --wait"'
else
  echo '"sc web codium"'
fi

if process::exists ssh-agent; then
  cat <<'EOF'
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [ ! -f "$SSH_AUTH_SOCK" ] && [ -f "$XDG_RUNTIME_DIR/ssh-agent.env" ]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi
EOF
fi

echo 'sc system status -q'
