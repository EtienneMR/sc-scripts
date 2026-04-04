# sc:alias po
# sc:complete * pacman -Qeq
# sc:complete 0 echo "--remove"
source "$SC_LIBS"
core::init
process::usage "sc pkg orphans [--remove] <packages...>" 0 + "$@"

REMOVE=0
if [ "${1:-}" = "--remove" ]; then
  REMOVE=1
  shift
fi

if [ "$#" -gt 0 ]; then
  log::info "Marking packages as deps"
  system::pm -D --asdeps "$@"
fi

mapfile -t ORPHANS < <(pacman -Qdtq)

if [ "${#ORPHANS[@]}" -eq 0 ]; then
  log::success "No orphaned packages"
  exit 0
fi

log::info "${#ORPHANS[@]} orphaned package(s):"
printf '  %s\n' "${ORPHANS[@]}"

if ((REMOVE)); then
  log::info "Removing orphans"
  system::pm -Rns "${ORPHANS[@]}"
fi
