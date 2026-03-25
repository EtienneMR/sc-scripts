source "$SC_LIBS"
core::init
process::usage "sc projects clone <url> [name]" 1 2 "$@"
process::require git

mkdir -p "$PROJECTS_DIR"

URL="$1"
NAME="${2:-$(basename "$URL" .git)}"
dir="$PROJECTS_DIR/$NAME"

if process::exists ssh; then
  BASE="git@github.com:"
else
  BASE="https://github.com/"
fi

[ -d "$dir" ] && log::die "Project already exists: $NAME"

case "${URL//[^\/]/}" in
  "") URL="${BASE}EtienneMR/$URL" ;;
  "/") URL="${BASE}$URL" ;;
esac

log::info "Cloning $URL to $dir"
git clone "$URL" "$dir"
log::success "Cloned to $dir"
