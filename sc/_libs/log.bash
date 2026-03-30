if [ "${NO_COLOR:-}" = "1" ]; then
  LOG_COLOR=0
elif [ "${KEEP_COLOR:-}" = "1" ] || [ -t 1 ]; then
  LOG_COLOR=1
else
  LOG_COLOR=0
fi

if ((LOG_COLOR)); then
  C_RESET=$'\033[0m'
  C_RED=$'\033[31m'
  C_GREEN=$'\033[32m'
  C_YELLOW=$'\033[33m'
  C_BLUE=$'\033[34m'
  C_GRAY=$'\033[90m'
else
  C_RESET=""
  C_RED=""
  C_GREEN=""
  C_YELLOW=""
  C_BLUE=""
  C_GRAY=""
fi

log::info() { printf "${C_BLUE}ℹ${C_RESET} %s\n" "$*"; }
log::success() { printf "${C_GREEN}✔${C_RESET} %s\n" "$*"; }
log::warn() { printf "${C_YELLOW}⚠${C_RESET} %s\n" "$*" >&2; }
log::error() { printf "${C_RED}✖${C_RESET} %s\n" "$*" >&2; }
log::debug() { [[ ${LOG_DEBUG:-0} == "1" ]] && printf "${C_GRAY}🐛${C_RESET} %s\n" "$*" || true; }
log::die() {
  log::error "$@"
  exit 1
}

log::column() {
  local width="$1" str="$2"
  local plain
  plain="$(printf '%s' "$str" | sed 's/\x1b\[[0-9;]*m//g')"
  local pad=$((width - ${#plain}))
  printf '%s%*s' "$str" "$pad" ""
}

log::status() {
  if ((LOG_COLOR)) && 2>/dev/null >&3; then
    printf "\r\033[K${C_BLUE}ℹ${C_RESET} %s" "$*" >&3
    _LOG_STATUS_PENDING=1
  else
    log::info "$@"
  fi
}
