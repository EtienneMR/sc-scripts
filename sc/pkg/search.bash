# sc:alias pss
# sc:complete + pacman -Slq
source "$SC_LIBS"
core::init
process::usage "sc pkg search <query...>" 1 + "$@"

system::pm -Ss "$@"
