source "$SC_LIBS"
core::init
process::usage "sc http serve [port] [dir]" 0 2 "$@"

PORT="${1:-0}"
DIR="${2:-$(pwd -P)}"

[ "$PORT" = 0 ] && process::random_port "PORT"

log::info "Serving $DIR on port $PORT"

python3 -m http.server -d "$DIR" "$PORT"
