# sc:alias mkt
source "$SC_LIBS"
core::init
process::usage "sc mkt [files-to-clone...]" 0 + "$@"
temp::dir DIR

[ "$#" -gt 0 ] && cp -r "$@" "$DIR"

export O="$(pwd)"

cd "$DIR"
"$SHELL"
