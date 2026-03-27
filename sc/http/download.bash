source "$SC_LIBS"
core::init
process::usage "sc http download <file> <url>" 2 2 "$@"
process::require HTTP_CLIENT "curl" "wget" "python"

OUT="$1"
URL="$2"

case "$HTTP_CLIENT" in
  curl)
    curl --fail --show-error --progress-bar --location "$URL" --output "$OUT"
    ;;
  wget)
    wget --output-document="$OUT" "$URL"
    ;;
  *)
    "$SC" http get "$URL" >"$OUT"
    ;;
esac
