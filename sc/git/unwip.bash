# sc:alias gunwip
source "$SC_LIBS"
core::init
process::require_args "$#" 0 0 "Usage: sc git unwip"
process::require git

last="$(git log -1 --format=%s)"
if [[ $last != WIP* ]]; then
  log::die "Last commit is not a WIP: $last"
fi
git reset HEAD~1
log::success "WIP restored"
