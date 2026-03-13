# sc:alias gunwip
source "$SC_LIBS"
core::init
process::require_args "$#" 0 0 "Usage: sc git unwip"
process::require GIT "git"

last="$("$GIT" log -1 --format=%s)"
if [[ "$last" != WIP* ]]; then
    log::die "last commit is not a wip: $last"
fi
"$GIT" reset HEAD~1
log::success "wip restored"
