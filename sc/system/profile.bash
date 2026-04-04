source "$SC_LIBS"
core::init
process::usage "sc system profile" 0 0 "$@"

cat <<'EOF'
export EDITOR='sc edit'

mkcd() { mkdir -p "$@" && cd "$_"; }
cdl() { cd "$1" && ls -lA; }

sc system status -q
EOF
