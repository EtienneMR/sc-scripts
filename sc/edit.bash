# sc:alias e
# sc:complete * compgen -fd -- "$COMP_CUR"
# sc:complete 0 printf "%s\n" "--code" "--shell" "--web" "--files"
source "$SC_LIBS"
core::init
process::usage "sc edit" 1 + "$@"

GROUP=""
TARGETS=()

for arg in "$@"; do
  case "$arg" in
    --*) GROUP="${arg#--}" ;;
    *)
      [ -e "$arg" ] || log::die "Not found: $arg"
      TARGETS+=("$(realpath "$arg")")
      ;;
  esac
done

shift_target() {
  TARGETS=("${TARGETS[@]:1}")
}

EDITORS=(code shell web files)

_edit::code() {
  process::select CODE codium code || return 1
  "$CODE" --wait "${TARGETS[@]}"
  TARGETS=()
}

_edit::shell() {
  process::exists nano || return 1
  [ -f "$TARGETS" ] || return 1
  if [ -w "$TARGETS" ]; then
    nano "$TARGETS"
  else
    process::exists sudo || return 1
    sudo nano "$TARGETS"
  fi
  shift_target
}

_edit::web() {
  [ -d "$TARGETS" ] || return 1
  "$SC" web codium "$TARGETS"
  shift_target
}

_edit::files() {
  process::exists dolphin || return 1
  [ -d "$TARGETS" ] || return 1
  dolphin "$TARGETS"
  shift_target
}

open() {
  for id in "${EDITORS[@]}"; do
    if [ -n "$GROUP" ] && [ "$id" != "$GROUP" ]; then
      continue
    fi
    log::debug "Trying editor $id"
    if "_edit::$id"; then
      return
    fi
  done
  log::die "No editor available${GROUP:+ in group '$GROUP'}"
}

while [ "${#TARGETS[@]}" -gt 0 ]; do
  open
done
