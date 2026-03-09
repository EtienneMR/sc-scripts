HTTP_CLIENT=""

_http::ensure_client() {
  [ -n "$HTTP_CLIENT" ] && return

  if process::exists curl; then
    HTTP_CLIENT="curl"
  elif process::exists wget; then
    HTTP_CLIENT="wget"
  else
    log::die "error: neither curl nor wget is available"
  fi
}

http::get() {
  local url="$1"

  _http::ensure_client

  log::debug "fetching $url using $HTTP_CLIENT"
  case "$HTTP_CLIENT" in
    curl)
      curl -fsSL "$url"
      ;;
    wget)
      wget -qO- "$url"
      ;;
  esac
}

http::download() {
  local out="$1"
  local url="$2"

  _http::ensure_client

  log::debug "downloading $url to $out using $HTTP_CLIENT"
  case "$HTTP_CLIENT" in
    curl)
      curl -fsSL# "$url" -o "$out"
      ;;
    wget)
      wget -qO --progress "$out" "$url"
      ;;
  esac
}
