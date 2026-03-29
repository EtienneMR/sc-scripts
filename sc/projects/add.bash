# sc:complete 0 compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc projects add <target> [name]" 1 2 "$@"
process::require git

TARGET="$(realpath "$1")"
NAME="${2:-$(basename "$TARGET")}"

[ -d "$TARGET/.git" ] || log::die "Not a project: $TARGET"

mkdir -p "$PROJECTS_DIR"

dir="$PROJECTS_DIR/$NAME"
[ -d "$dir" ] && log::die "Project already exists: $NAME"

fs::link "$TARGET" "$dir"
log::success "Added $TARGET to project list"
