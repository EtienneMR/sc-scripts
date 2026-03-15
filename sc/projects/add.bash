source "$SC_LIBS"
core::init
process::require git
process::require_args "$#" 0 2 "Usage: sc projects add [target] [name]"

if [ "$#" -ge 1 ]; then
  TARGET="$(realpath "$1")"
else
  TARGET="$(projects::find)"
fi
NAME="${2:-$(basename "$TARGET")}"

[ -d "$TARGET/.git" ] || log::die "Not a project: $TARGET"

mkdir -p "$PROJECTS_DIR"

dir="$PROJECTS_DIR/$NAME"
[ -d "$dir" ] && log::die "Project already exists: $NAME"

ln -s "$TARGET" "$dir"
log::success "Added $TARGET to project list"
