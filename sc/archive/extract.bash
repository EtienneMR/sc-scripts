# sc:alias aex
# sc:complete 0 compgen -f -- "$COMP_CUR"
# sc:complete 1 compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc archive extract <archive> [output_dir]" 1 2 "$@"

SOURCE="$(realpath "$1")"
[ -f "$SOURCE" ] || log::die "Archive not found: $SOURCE"

SRC_DIR="$(dirname "$SOURCE")"
SRC_BASE="$(basename "$SOURCE")"
STEM="${SRC_BASE%%.*}"

case "$SOURCE" in
  *.tar.gz | *.tgz)   TAR_FLAG="z" ;;
  *.tar.bz2 | *.tbz2) TAR_FLAG="j" ;;
  *.tar.xz | *.txz)   TAR_FLAG="J" ;;
  *.tar | *.zip)      TAR_FLAG=""  ;;
  *) log::die "Unknown archive format: $SRC_BASE (supported: .tar.gz .tar.bz2 .tar.xz .tar .zip)" ;;
esac

_top_level_entries() {
  if [ "$SRC_BASE" != "${SRC_BASE%.zip}" ]; then
    process::require unzip
    # unzip -Z1 prints one path per line; strip everything after first /
    unzip -Z1 "$SOURCE" | sed 's|/.*||' | sort -u
  else
    tar "t${TAR_FLAG}f" "$SOURCE" | sed 's|/.*||' | sort -u
  fi
}

mapfile -t TOP < <(_top_level_entries)

if [ -n "${2:-}" ]; then
  OUTPUT="$(realpath "$2")"
elif [ "${#TOP[@]}" -eq 1 ] && [ "${TOP[0]}" = "$STEM" ]; then
  OUTPUT="$SRC_DIR"
  log::debug "Single entry '${TOP[0]}' matches archive stem — extracting into $SRC_DIR"
else
  OUTPUT="$SRC_DIR/$STEM"
fi

mkdir -p "$OUTPUT" || log::die "Could not create output directory: $OUTPUT"

log::info "Extracting $SRC_BASE → $OUTPUT"

if [ "$SRC_BASE" != "${SRC_BASE%.zip}" ]; then
  unzip -q "$SOURCE" -d "$OUTPUT"
else
  tar "x${TAR_FLAG}f" "$SOURCE" -C "$OUTPUT"
fi

EXTRACTED="$(find "$OUTPUT" -mindepth 1 | wc -l | tr -d ' ')"
log::success "Extracted $EXTRACTED items → $OUTPUT"
