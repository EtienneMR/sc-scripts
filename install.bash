#!/bin/bash
# Install sc on a fresh machine.
#
# Usage:
#   curl -fL https://raw.githubusercontent.com/EtienneMR/sc-scripts/main/install.bash | bash
#
set -euo pipefail

REPO="https://github.com/EtienneMR/sc-scripts"
DEST="$HOME/.local/apps/sc-scripts"

_info() { printf '\033[34mℹ\033[0m %s\n' "$*"; }
_die() {
  printf '\033[31m✖\033[0m %s\n' "$*" >&2
  exit 1
}

command -v python3 >/dev/null 2>&1 || _die "python3 is required"
command -v git >/dev/null 2>&1 || _die "git is required"

if [ -d "$DEST/.git" ]; then
  _info "Updating sc in $DEST"
  python3 "$DEST/sc/__main__.py" self update
else
  _info "Installing sc to $DEST"
  git clone --quiet "$REPO" "$DEST"
  python3 "$DEST/sc/__main__.py" self install
fi
