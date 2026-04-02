source "$SC_LIBS"
core::init
process::usage "sc system update" 0 0 "$@"
state::dir "system" STATE_DIR

_update() {
  local name="$1"
  shift
  process::exists "$name" || return 0
  log::info "Updating $name"
  "$@" || log::warn "$name update failed"
}

_prompt_reboot() {
  system::reboot_required || return 0
  log::warn "Reboot required"
  local reply
  read -r -p "Reboot now? [y/N] " reply </dev/tty
  [[ $reply =~ ^[Yy]$ ]] && sudo reboot
}

log::info "Updating sc"
if "$SC" self update; then
  exec "$SC" system update
fi

if process::exists pacman; then
  log::info "Upgrading system packages"
  system::pm -Syu || true
  "$SC" pkg orphans --remove
fi

_update flatpak flatpak update --user
_update flatpak sudo flatpak update --system

_update rustup rustup update
_update uv uv tool upgrade --all
_update pipx pipx upgrade-all
_update npm npm update -g
_update pnpm pnpm update -g

_update mandb sudo mandb -q
_update updatedb sudo updatedb
_update journalctl sudo journalctl --vacuum-time=30d

if process::exists fwupdmgr; then
  log::info "Updating firmware"
  fwupdmgr refresh || true
  fwupdmgr upgrade || true
fi

touch "$STATE_DIR/updated"
_prompt_reboot
log::success "Done"
