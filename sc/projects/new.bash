source "$SC_LIBS"
core::init
process::usage "sc projects new <name>" 1 1 "$@"
process::require git

mkdir -p "$PROJECTS_DIR"

dir="$PROJECTS_DIR/$1"
[ -d "$dir" ] && log::die "Project already exists: $1"

mkdir "$dir"
git -C "$dir" init
log::success "Created $dir"
