HTTP_CLIENT=""

_http::ensure_client() {
  [ -n "$HTTP_CLIENT" ] && return
  process::require HTTP_CLIENT "curl" "wget"
}

http::get() {
  local url="$1"

  _http::ensure_client

  log::debug "Fetching $url"
  case "$HTTP_CLIENT" in
    curl)
      curl --fail --show-error --location "$url"
      ;;
    wget)
      wget --output-document=- "$url"
      ;;
  esac
}

http::download() {
  local out="$1"
  local url="$2"

  _http::ensure_client

  log::debug "Downloading $url to $out"
  case "$HTTP_CLIENT" in
    curl)
      curl --fail --show-error --silent --progress-bar --location "$url" --output "$out"
      ;;
    wget)
      wget --output-document="$out" "$url"
      ;;
  esac
}
