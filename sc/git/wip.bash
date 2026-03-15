# sc:alias gwip
source "$SC_LIBS"
core::init
process::require_args "$#" 0 1 "Usage: sc git wip [message]"
process::require "git"

"$SC" git unwip 2>/dev/null || true

git add -A
git commit -m "WIP: ${*:-wip}"
log::success "wip saved"
