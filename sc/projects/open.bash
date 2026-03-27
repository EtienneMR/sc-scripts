# sc:complete 0 ls -1 "${SC_PROJECTS_DIR:-$HOME/projects}" 2>/dev/null
source "$SC_LIBS"
process::usage "sc projects open [name]" 0 1 "$@"
core::init

exec $EDITOR "$(projects::find "$@")"
