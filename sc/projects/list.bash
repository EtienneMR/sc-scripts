source "$SC_LIBS"
core::init
process::usage "sc projects list" 0 0 "$@"
process::require git

log::column 30 "${C_BLUE}PROJECT${C_RESET}"
log::column 20 "${C_GRAY}BRANCH${C_RESET}"
printf '%s\n' "LAST COMMIT"

for dir in "$PROJECTS_DIR"/*/; do
  [ -d "$dir/.git" ] || continue

  branch="$(git -C "$dir" symbolic-ref --short HEAD || git -C "$dir" rev-parse --short HEAD)"
  dirty="$(git -C "$dir" status --porcelain | wc -l | tr -d ' ')"
  last="$(git -C "$dir" log -1 --format="%s (%cr)" 2>/dev/null || true)"

  link_flag=""
  [ -L "$dir" ] && link_flag=" ${C_YELLOW}l${C_RESET}"

  dirty_flag=""
  [ "$dirty" -gt 0 ] && dirty_flag=" ${C_YELLOW}*${dirty}${C_RESET}"

  log::column 30 "$(basename "$dir")$link_flag"
  log::column 20 "${branch}"
  printf '%s\n' "${last:-no commits}${dirty_flag}"
done
