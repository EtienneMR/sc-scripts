source "$SC_LIBS"
core::init
process::require_args "$#" 1 1 "Usage: sc projects remove <name>"

PROJECT="$(projects::find "$@")"

if [ -L "$PROJECT" ]; then
  log::success "Removed $(readlink "$PROJECT") from project list"
  rm "$PROJECT"
else
  [ -n "$(git -C "$PROJECT" status --porcelain)" ] && log::die "Cannot remove a project with changes"

  rm -rf "$PROJECT"
  log::success "Removed project"
fi
