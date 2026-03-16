source "$SC_LIBS"
core::init

rc_file() {
  case "$(process::detect_shell)" in
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

RC=$(rc_file)
log::info "Updating $RC"

"$SC" utils append "$RC" "# SC INSTALL" <<EOF
export PATH="\$HOME/.local/bin:\$PATH"
$("$SC" self profile)
EOF

"$SC" utils append "$RC" "# SC SYSTEM PROFILE" <<EOF
$("$SC" system profile)
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
  systemctl --user reenable --now sc-tray
fi

log::success "Done. Reload your shell: source $RC"
