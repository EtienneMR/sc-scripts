source "$SC_LIBS"
core::init
process::require git
process::require_args "$#" 1 2 "usage: sc projects clone <url> [name]"

mkdir -p "$PROJECTS_DIR"

URL="$1"
NAME="${2:-$(basename "$URL" .git)}"
dir="$PROJECTS_DIR/$NAME"

[ -d "$dir" ] && log::die "project already exists: $NAME"

case "${URL//[^\/]}" in
    "") URL="git@github.com:EtienneMR/$URL" ;;
    "/") URL="git@github.com:$URL" ;;
esac

log::info "Cloning $URL"
git clone "$URL" "$dir"
log::success "Cloned to $dir"
