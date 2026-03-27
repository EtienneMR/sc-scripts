# sc:alias aco
# sc:complete 0 compgen -fd -- "$COMP_CUR"
# sc:complete 1 compgen -f -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc archive compress <source> [output]" 1 2 "$@"

SOURCE="$(realpath "$1")"
[ -e "$SOURCE" ] || log::die "Source not found: $SOURCE"

SRC_BASE="$(basename "$SOURCE")"
SRC_DIR="$(dirname "$SOURCE")"

[[ $1 == */ ]] && ROOT="$SOURCE" || ROOT="$SRC_DIR"

OUTPUT="${2:+"$(realpath "$2")"}"
OUTPUT="${OUTPUT:-"$SRC_DIR/$SRC_BASE.tar.gz"}"

log::info "Compressing $SRC_BASE → $(basename "$OUTPUT")"

fs::all_files FILES "$SOURCE"
RELATIVE=("${FILES[@]#"$ROOT/"}")

case "$OUTPUT" in
  *.tar.gz | *.tgz) tar_flag="z" ;;
  *.tar.bz2 | *.tbz2) tar_flag="j" ;;
  *.tar.xz | *.txz) tar_flag="J" ;;
  *.tar) tar_flag="" ;;
  *.zip)
    process::require zip
    (cd "$ROOT" && zip "$OUTPUT" "${RELATIVE[@]}")
    exit $?
    ;;
  *) log::die "Unknown archive format: $OUTPUT (supported: .tar.gz .tar.bz2 .tar.xz .tar .zip)" ;;
esac

tar "cf$tar_flag" "$OUTPUT" -C "$ROOT" --checkpoint=1000 --checkpoint-action='exec=printf "#"' "${RELATIVE[@]}"
