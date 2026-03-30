# sc:alias gs
source "$SC_LIBS"
core::init
process::usage "sc git ship" 0 0 "$@"
process::require git

prompt_choice() {
  local prompt="$1" default="$2" reply
  read -e -p "$prompt" reply
  reply=${reply:-$default}
  printf '%s' "$reply"
}

if "$SC" git unwip 2>/dev/null; then
  log::info "Restored WIP state"
fi

if [[ -f .gitignore ]]; then
  git add -- .
else
  fs::find FILES .
  git add -- "${FILES[@]}"
fi

if ! git diff --cached --quiet; then
  read -e -p "msg: " MESSAGE
  [[ -n ${MESSAGE:-} ]] || log::die "Empty commit message"
  git commit -m "$MESSAGE"
  log::info "Committed files"
fi

log::info "Fetching remote"
git fetch --prune

LOCAL=$(git rev-parse --verify HEAD)
REMOTE=$(git rev-parse --verify @{u}) || log::die "No upstream configured"
BASE=$(git merge-base HEAD @{u})

if [[ $LOCAL == "$REMOTE" ]]; then
  log::die "Already up-to-date"
fi

if [[ $LOCAL == "$BASE" ]]; then
  log::info "Local branch is behind upstream"
  case "$(prompt_choice "rebase ? [Y/n] " y)" in
    [yY])
      PUSH_MODE=rebase
      ;;
    [nN]) PUSH_MODE=none ;;
    *) log::die "Invalid option" ;;
  esac
elif [[ $REMOTE == "$BASE" ]]; then
  PUSH_MODE=normal
else
  log::warn "Divergent history"
  case "$(prompt_choice "push ? [(y)es/(r)ebase/(f)orce/(N)o] " N)" in
    [yY]) PUSH_MODE=normal ;;
    [rR]) PUSH_MODE=rebase ;;
    [fF]) PUSH_MODE=force ;;
    [nN]) PUSH_MODE=none ;;
    *) log::die "Invalid option" ;;
  esac
fi

if [ "$PUSH_MODE" = "rebase" ]; then
  log::info "Rebasing commits"
  git rebase @{u}
  PUSH_MODE=normal
fi

case "$PUSH_MODE" in
  normal)
    log::info "Pushing changes"
    git push
    ;;
  force)
    log::info "Force pushing changes"
    "$SC" git push-forced
    ;;
esac

log::success "Done"
