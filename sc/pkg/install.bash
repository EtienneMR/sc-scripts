# sc:alias pi
# sc:complete + pacman -Slq
source "$SC_LIBS"
core::init
process::usage "sc pkg install <package...>" 1 + "$@"

system::pm -S "$@"
