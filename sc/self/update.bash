source "$SC_LIBS"
core::init
process::require "git"

log::info "Fetching updates"
git -C "$SC_ROOT" fetch --quiet

if [ "$(git -C "$SC_ROOT" rev-list HEAD..origin/main --count)" -gt 0 ]; then
  log::info "Applying updates"
  git -C "$SC_ROOT" reset --quiet --hard origin/HEAD

  log::info "Running install script"
  exec "$SC" self install
else
  log::info "Already up-to-date"
  exit 1
fi
