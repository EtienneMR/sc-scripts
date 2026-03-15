source "$SC_LIBS"
core::init
process::require git
process::require_args "$#" 0 0 "Usage: sc projects list"

_project_status() {
    local dir="$1"
    local branch dirty last

    branch="$(git -C "$dir" symbolic-ref --short HEAD || git -C "$dir" rev-parse --short HEAD)"
    dirty="$(git -C "$dir" status --porcelain | wc -l | tr -d ' ')"
    last="$(git -C "$dir" log -1 --format="%s (%cr)" 2>/dev/null || true)"

    local link_flag=""
    [ -L "$dir" ] && link_flag=" ${C_YELLOW}l${C_RESET}"

    local dirty_flag=""
    [ "$dirty" -gt 0 ] && dirty_flag=" ${C_YELLOW}*${dirty}${C_RESET}"

    log::column 30 "$(basename "$dir")$link_flag"
    log::column 20 "${branch}"
    printf '%s\n' "${last:-no commits}${dirty_flag}"
}

log::column 30 "${C_BLUE}PROJECT${C_RESET}"
log::column 20 "${C_GRAY}BRANCH${C_RESET}"
printf '%s\n' "LAST COMMIT"

while IFS= read -r dir; do
    [ -d "$dir/.git" ] || continue
    _project_status "$dir"
done < <(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 | sort)
