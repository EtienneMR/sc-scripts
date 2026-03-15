source "$SC_LIBS"
core::init
process::require git
process::require_args "$#" 1 1 "Usage: sc projects new <name>"

mkdir -p "$PROJECTS_DIR"

dir="$PROJECTS_DIR/$1"
[ -d "$dir" ] && log::die "Project already exists: $1"

mkdir "$dir"
git -C "$dir" init
log::success "Created $dir"
