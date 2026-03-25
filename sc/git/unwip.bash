# sc:alias guw
source "$SC_LIBS"
core::init
process::usage "sc git unwip" 0 0 "$@"
process::require git

last="$(git log -1 --format=%s)"
if [[ $last != WIP* ]]; then
  log::die "Last commit is not a WIP: $last"
fi
git reset HEAD~1
log::success "WIP restored"
