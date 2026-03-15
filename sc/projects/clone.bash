source "$SC_LIBS"
core::init
process::require git
process::require_args "$#" 1 2 "usage: sc projects clone <url> [name]"

mkdir -p "$PROJECTS_DIR"

URL="$1"
NAME="${2:-$(basename "$URL" .git)}"
dir="$PROJECTS_DIR/$NAME"

if process::exists ssh; then
  BASE="git@github.com:"
else
  BASE="https://github.com/"
fi

[ -d "$dir" ] && log::die "project already exists: $NAME"

case "${URL//[^\/]/}" in
  "") URL="${BASE}EtienneMR/$URL" ;;
  "/") URL="${BASE}$URL" ;;
esac

log::info "Cloning $URL to $dir"
git clone "$URL" "$dir"
log::success "Cloned to $dir"
