# sc:alias aex
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
  *.tar.gz | *.tgz) tar_flag="-xzf" ;;
  *.tar.bz2 | *.tbz2) tar_flag="-xjf" ;;
  *.tar.xz | *.txz) tar_flag="-xJf" ;;
  *.tar) tar_flag="-xf" ;;
  *.zip)
    process::require unzip
    unzip -q "$OUTPUT" "$SOURCE"
    ;;
  *) log::die "Unknown archive format: $SRC_BASE (supported: .tar.gz .tar.bz2 .tar.xz .tar .zip)" ;;
esac

tar "$tar_flag" "$SOURCE" -C "$OUTPUT"
