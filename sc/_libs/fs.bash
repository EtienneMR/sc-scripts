FS_EXCLUDE_NAMES=(
  ".*"
  node_modules
  __pycache__
  target
  dist
  build
)

fs::link() {
  local source="$1"
  local target="$2"
  local relative="$(realpath --relative-to="$(dirname "$target")" "$source")"

  log::debug "Linking $source to $target"
  ln -sfn "$relative" "$target"
}

fs::all_files() {
  local _var="$1"
  shift
  local roots=("${@:-.}")

  local exclude=()
  for _name in "${FS_EXCLUDE_NAMES[@]}"; do
    exclude+=(-not -path "*/$_name/*")
  done

  mapfile -t "$_var" < <(find "${roots[@]}" "${exclude[@]}" -type f | sort)
}

fs::each_ext() {
  local action="$1"
  local prefix="$2"
  shift 2

  local all_files
  fs::all_files all_files "$@"

  local extensions
  mapfile -t extensions < <(printf '%s\n' "${all_files[@]}" | grep -oE '\.[^./]+$' | sort -u | tr -d '.')

  for ext in "${extensions[@]}"; do
    local fn="${prefix}_${ext}"
    declare -F "$fn" >/dev/null || continue
    local files
    mapfile -t files < <(printf '%s\n' "${all_files[@]}" | grep -E "\.$ext$")
    log::info "$action ${#files[@]} .$ext files"
    "$fn" "${files[@]}"
  done
}
