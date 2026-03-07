LIB_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

core::init() {
    set -euo pipefail
    trap core::_exit EXIT INT TERM
    log::debug "Initied core"
}

core::_exit() {
    log::debug "Exiting script"
    temp::cleanup
    lock::release
}

for lib in "$LIB_DIR"/*.bash
do
    [ "$(basename "$lib")" = "$(basename "${BASH_SOURCE[0]}")" ] && continue
    source "$lib"
done
