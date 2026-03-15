source "$SC_LIBS"
core::init
process::require git
process::require_args "$#" 0 1 "Usage: sc projects standup [days]"

DAYS="${1:-}"
SINCE="${DAYS:-1} days ago"
AUTHOR="$(git config --global user.email 2>/dev/null)"
[ -n "$AUTHOR" ] || log::die "git user.email not set"

found=0
while IFS= read -r dir; do
    [ -d "$dir/.git" ] || continue

    mapfile -t commits < <(git -C "$dir" log \
        --since="$SINCE" \
        --author="$AUTHOR" \
        --format="%s (%cr)" 2>/dev/null)

    [ "${#commits[@]}" -eq 0 ] && continue

    printf "${C_BLUE}%s${C_RESET}\n" "$(basename "$dir")"
    printf "  %s\n" "${commits[@]}"
    found=1
done < <(find "$PROJECTS_DIR" -mindepth 1 -maxdepth 1 | sort)

if [ "$found" -eq 0 ]; then
    if [ -n "$DAYS" ]; then
        log::info "No commits in the last $DAYS day(s)"
    else
        exec sc projects standup 3
    fi
fi
