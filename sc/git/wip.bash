# sc:alias gw
source "$SC_LIBS"
core::init
process::usage "sc git wip [message]" 0 1 "$@"
process::require git

"$SC" git unwip 2>/dev/null || true

git add -A
git commit -m "WIP: ${*:-wip}"
log::success "WIP saved"
