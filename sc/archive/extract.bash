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
OUTPUT="${2:+"$(realpath "$2")"}"
OUTPUT="${OUTPUT:-"$SRC_DIR/${SRC_BASE%%.*}"}"

mkdir -p "$OUTPUT" || log::die "Could not create output directory: $OUTPUT"

log::info "Extracting $SRC_BASE → $OUTPUT"

case "$SOURCE" in
  *.tar.gz | *.tgz) tar_flag="z" ;;
  *.tar.bz2 | *.tbz2) tar_flag="j" ;;
  *.tar.xz | *.txz) tar_flag="J" ;;
  *.tar) tar_flag="" ;;
  *.zip)
    process::require unzip
    unzip -q "$OUTPUT" "$SOURCE"
    ;;
  *) log::die "Unknown archive format: $SRC_BASE (supported: .tar.gz .tar.bz2 .tar.xz .tar .zip)" ;;
esac

tar "xf$tar_flag" "$SOURCE" -C "$OUTPUT" --checkpoint=1000 --checkpoint-action='exec=printf "#"'
