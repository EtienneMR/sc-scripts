source "$SC_LIBS"
core::init
process::usage "sc http download <file> <url>" 2 2 "$@"

OUT="$1"
URL="$2"

process::select HTTP_CLIENT "curl" "wget" || "$SC" http get "$URL" >"$OUT"

case "$HTTP_CLIENT" in
  curl)
    curl --fail --show-error --progress-bar --location "$URL" --output "$OUT"
    ;;
  wget)
    wget --output-document="$OUT" "$URL"
    ;;
esac
