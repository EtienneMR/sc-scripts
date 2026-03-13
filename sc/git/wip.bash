# sc:alias gwip
source "$SC_LIBS"
core::init
process::require_args "$#" 0 1 "Usage: sc git wip [message]"
process::require GIT "git"

"$SC" git unwip 2>/dev/null || true

"$GIT" add -A
"$GIT" commit -m "WIP: ${*:-wip}"
log::success "wip saved"
