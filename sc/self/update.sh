source "$("$SC" libs bash)"
core::init
process::require "git"

cd "$SC_ROOT"

log::info "Updating repository"
git fetch
git reset --hard origin/HEAD

log::info "Running install script"
exec "$SC" self install
