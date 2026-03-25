# sc:alias gpf
source "$SC_LIBS"
core::init
process::usage "sc git push-forced" 0 0 "$@"
process::require git

git push --force-with-lease
