#!/bin/bash

SCRIPTS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

source "$SCRIPTS_DIR/lib/core.bash"
core::init


current_shell() { basename "${SHELL:-sh}"; }

rc_file() {
  case "$(current_shell)" in
    zsh)  printf '%s/.zshrc'                   "$HOME" ;;
    bash) printf '%s/.bashrc'                  "$HOME" ;;
    ksh)  printf '%s/.kshrc'                   "$HOME" ;;
    fish) printf '%s/.config/fish/config.fish' "$HOME" ;;
    *)    printf '%s/.profile'                 "$HOME" ;;  # POSIX fallback
  esac
}

append_once() {
  file="$1"; marker="$2"; content="$3"
  grep -qF "$marker" "$file" 2>/dev/null || printf '\n%s\n' "$content" >> "$file"
}


log::info "Setting permissions on bin/"
find "$SCRIPTS_DIR/bin" -type f -exec chmod +x {} \;


RC=$(rc_file)
log::info "Updating $RC"

RELATIVE_PATH=$(echo "$SCRIPTS_DIR" | sed "s|$HOME|\"\$HOME\"|g")
if [ "$(current_shell)" = "fish" ]; then
  append_once "$RC" "scripts/bin" \
    "fish_add_path \"$RELATIVE_PATH/bin\""
else
  append_once "$RC" "scripts/bin" \
    "export PATH=\"$RELATIVE_PATH/bin:\$PATH\""
fi


log::success "Done. Reload your shell: exec $SHELL"
