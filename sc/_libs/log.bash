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
log::overwrite() {
  if ((LOG_COLOR)); then
    printf "\r\033[K"
    tr -d "\n"
  else
    cat
  fi
}
