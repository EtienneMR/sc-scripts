source "$SC_LIBS"
core::init
process::require_args "$#" 0 1 "Usage: sc projects open [name]"

exec "$EDITOR" "$(projects::find "$@")"
