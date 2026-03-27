# sc:complete 0 ls -1 "${SC_PROJECTS_DIR:-$HOME/projects}" 2>/dev/null
source "$SC_LIBS"
process::usage "sc projects remove <name>" 1 1 "$@"
core::init

PROJECT="$(projects::find "$@")"

if [ -L "$PROJECT" ]; then
  log::success "Removed $(readlink "$PROJECT") from project list"
  rm "$PROJECT"
else
  [ -n "$(git -C "$PROJECT" status --porcelain)" ] && log::die "Cannot remove a project with changes"

  rm -rf "$PROJECT"
  log::success "Removed project"
fi
