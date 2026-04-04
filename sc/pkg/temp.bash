# sc:alias pt
# sc:complete * pacman -Slq
source "$SC_LIBS"
core::init
process::usage "sc pkg temp <package...>" 1 + "$@"

system::pm -S --asdeps "$@"
