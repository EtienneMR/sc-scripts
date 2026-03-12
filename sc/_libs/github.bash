github::latest() {
  "$SC" utils github-latest "$1" || log::die "Could not fetch latest release for $1"
}

github::ensure() {
  local name="$1"
  local repo="$2"
  local version_file="$3"
  local install_fn="$4"
  shift 4

  local latest installed=""
  latest="$(github::latest "$repo")"

  [ -f "$version_file" ] && installed="$(cat "$version_file")"

  if [ "$installed" = "$latest" ]; then
    log::debug "$name $installed is up to date"
    return
  fi

  if [ -z "$installed" ]; then
    log::info "Installing $name $latest"
  else
    log::info "Updating $name $installed → $latest"
  fi

  "$install_fn" "$latest" "$@"
  echo "$latest" >"$version_file"
}
