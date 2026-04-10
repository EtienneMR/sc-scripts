source "$SC_LIBS"
core::init
process::usage "sc self install" 0 0 "$@"

TARGET_SHELL="$(process::detect_shell)"

rc_file() {
  case "$TARGET_SHELL" in
    zsh) printf '%s/.zshrc' "$HOME" ;;
    bash) printf '%s/.bashrc' "$HOME" ;;
    ksh) printf '%s/.kshrc' "$HOME" ;;
    fish) printf '%s/.config/fish/config.fish' "$HOME" ;;
    *) printf '%s/.profile' "$HOME" ;; # POSIX fallback
  esac
}

LOCAL_BIN="$HOME/.local/bin"
log::info "Adding sc to $LOCAL_BIN"
mkdir -p "$LOCAL_BIN"
fs::link "$SC" "$LOCAL_BIN/sc"

log::info "Running migrations"
for script in "$SC_ROOT/sc/_migrations"/*; do
  log::debug "Applying migration $script"
  bash "$script"
done

RC=$(rc_file)
log::info "Updating $RC"

"$SC" utils append "$RC" "# SC INSTALL" <<EOF
export PATH="\$HOME/.local/bin:\$PATH"
$(LOG_DEBUG=0 "$SC" self profile)
EOF

"$SC" utils append "$RC" "# SC SYSTEM PROFILE" <<EOF
$(LOG_DEBUG=0 "$SC" system profile)
EOF

if process::exists yad; then
  SERVICE_DIR="$HOME/.config/systemd/user"
  log::info "Installing tray service"
  mkdir -p "$SERVICE_DIR"
  cat >"$SERVICE_DIR/sc-tray.service" <<EOF
[Unit]
Description=sc system tray

[Service]
ExecStart=$SC system tray
Restart=on-failure

[Install]
WantedBy=default.target
EOF
  systemctl --user daemon-reload
  systemctl --user enable --now sc-tray
fi

log::success "Done. Reload your shell: exec $TARGET_SHELL"
