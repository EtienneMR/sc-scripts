source "$SC_LIBS"
core::init

_py_run() {
  if process::exists "$1"; then
    "$@"
  elif process::exists uvx; then
    uvx "$@"
  elif process::exists pipx; then
    pipx run "$@"
  else return 1; fi
}

_js_run() {
  if process::exists "$1"; then
    "$@"
  elif process::exists pnpx; then
    pnpx "$@"
  elif process::exists bunx; then
    bunx "$@"
  elif process::exists npx; then
    npx --yes "$@"
  else return 1; fi
}

_format_py() {
  _py_run ruff format --quiet "$@" ||
    _py_run black --quiet "$@" ||
    log::warn "No formatter for .py (install ruff, black or uvx/pipx)"
}

_format_prettier() { _js_run prettier --write --log-level=warn "$@" || log::warn "No formatter for .js (install prettier or npx/pnpx/bunx)"; }
_format_js() { _format_prettier "$@"; }
_format_ts() { _format_prettier "$@"; }
_format_css() { _format_prettier "$@"; }
_format_html() { _format_prettier "$@"; }
_format_json() { _format_prettier "$@"; }
_format_yaml() { _format_prettier "$@"; }
_format_yml() { _format_prettier "$@"; }
_format_md() { _format_prettier "$@"; }

_format_c() { _py_run clang-format -i "$@" || log::warn "No formatter for .c (install clang-format or uvx/pipx)"; }
_format_cpp() { _format_c "$@"; }
_format_h() { _format_c "$@"; }
_format_hpp() { _format_c "$@"; }

_format_sh() { process::exists shfmt && shfmt --write --indent 2 --simplify --case-indent "$@" || log::warn "No formatter for .sh (install shfmt)"; }
_format_bash() { _format_sh "$@"; }

_format_rs() { process::exists rustfmt && rustfmt "$@" || log::warn "No formatter for .rs (install rustfmt)"; }
_format_go() { process::exists gofmt && gofmt -w "$@" || log::warn "No formatter for .go (install gofmt)"; }
_format_lua() { process::exists stylua && stylua "$@" || log::warn "No formatter for .lua (install stylua)"; }

ROOTS=("${@:-.}")
EXCLUDE_NAMES=(
  ".*"
  node_modules
  __pycache__
  target
  dist
  build
)

EXCLUDE=()
for _name in "${EXCLUDE_NAMES[@]}"; do
  EXCLUDE+=(-not -path "*/$_name/*")
done

mapfile -t ALL_FILES < <(find "${ROOTS[@]}" "${EXCLUDE[@]}" -type f | sort)

mapfile -t EXTENSIONS < <(printf '%s\n' "${ALL_FILES[@]}" | grep -oE '\.[^./]+$' | sort -u | tr -d '.')

for ext in "${EXTENSIONS[@]}"; do
  fn="_format_$ext"
  declare -F "$fn" >/dev/null || continue
  mapfile -t files < <(printf '%s\n' "${ALL_FILES[@]}" | grep -E "\.$ext$")
  log::info "Formatting ${#files[@]} .$ext files"
  log::debug "Formatting ${files[@]}"
  "$fn" "${files[@]}" || log::error "Failled to format files"
done
