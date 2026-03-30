# sc:alias mkt
source "$SC_LIBS"
core::init
temp::dir DIR

log::info "Using temp dir $DIR"

[ "$#" -gt 0 ] && cp -r "$@" "$DIR"

cd "$DIR"
"$SHELL"
