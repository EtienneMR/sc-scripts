source "$SC_LIBS"
core::init
process::require "git"

cd "$SC_ROOT"

log::info "updating repository"
git fetch
git reset --hard origin/HEAD

log::info "running install script"
exec "$SC" self install
