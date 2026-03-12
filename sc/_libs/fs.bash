EXCLUDE_NAMES=(
  ".*"
  node_modules
  __pycache__
  target
  dist
  build
)

fs::each_ext() {
  local action="$1"
  local prefix="$2"
  shift 2
  local roots=("${@:-.}")

  local exclude=()
  for _name in "${FS_EXCLUDE_NAMES[@]}"; do
    exclude+=(-not -path "*/$_name/*")
  done

  local all_files extensions
  mapfile -t all_files < <(find "${roots[@]}" "${exclude[@]}" -type f | sort)
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
