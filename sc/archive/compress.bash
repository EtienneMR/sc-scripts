# sc:alias aco
source "$SC_LIBS"
core::init
process::usage "sc archive compress <source> [output]" 1 2 "$@"

SOURCE="$(realpath "$1")"
[ -e "$SOURCE" ] || log::die "Source not found: $SOURCE"

SRC_DIR="$(dirname "$SOURCE")"
SRC_BASE="$(basename "$SOURCE")"
OUTPUT="${2:+"$(realpath "$2")"}"
OUTPUT="${OUTPUT:-"$SRC_DIR/$SRC_BASE.tar.gz"}"

log::info "Compressing $SRC_BASE → $(basename "$OUTPUT")"

fs::all_files FILES "$SOURCE"
RELATIVE=("${FILES[@]#"$SRC_DIR/"}")

case "$OUTPUT" in
  *.tar.gz | *.tgz) tar_flag="-czf" ;;
  *.tar.bz2 | *.tbz2) tar_flag="-cjf" ;;
  *.tar.xz | *.txz) tar_flag="-cJf" ;;
  *.tar) tar_flag="-cf" ;;
  *.zip)
    process::require zip
    (cd "$SRC_DIR" && zip "$OUTPUT" "${RELATIVE[@]}")
    exit $?
    ;;
  *) log::die "Unknown archive format: $OUTPUT (supported: .tar.gz .tar.bz2 .tar.xz .tar .zip)" ;;
esac

tar "$tar_flag" "$OUTPUT" -C "$SRC_DIR" "${RELATIVE[@]}"
