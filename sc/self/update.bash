source "$SC_LIBS"
core::init
process::require GIT "git"

log::info "Updating repository"
"$GIT" -C "$SC_ROOT" fetch --quiet
"$GIT" -C "$SC_ROOT" reset --quiet --hard origin/HEAD

log::info "Running install script"
exec "$SC" self install
