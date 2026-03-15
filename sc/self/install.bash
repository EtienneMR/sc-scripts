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

append_once() {
  file="$1"
  marker="$2"
  content="$3"
  grep -qF "$marker" "$file" 2>/dev/null || printf '\n%s\n' "$content" >>"$file"
}

LOCAL_BIN="$HOME/.local/bin"
log::info "Adding sc to $LOCAL_BIN"
mkdir -p "$LOCAL_BIN"
ln --symbolic --force "$SC" "$LOCAL_BIN/sc"

RC=$(rc_file)
log::info "Updating $RC"

"$SC" utils append "$RC" "# SC INSTALL" <<EOF
export PATH="\$HOME/.local/bin:\$PATH"
$("$SC" self profile)
EOF

"$SC" utils append "$RC" "# SC SYSTEM PROFILE" <<EOF
$("$SC" system profile)
EOF

log::success "Done. Reload your shell: source $RC"
