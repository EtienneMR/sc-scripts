source "$SC_LIBS"
core::init
process::require GIT "git"

cd "$SC_ROOT"

log::info "updating repository"
"$GIT" fetch
"$GIT" reset --hard origin/HEAD

log::info "running install script"
exec "$SC" self install
