# sc:alias gpf
source "$SC_LIBS"
core::init
process::require_args "$#" 0 0 "Usage: sc git psh-forced"
process::require git

git push --force-with-lease
