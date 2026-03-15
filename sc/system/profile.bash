cat <<'EOF'
mkcd() { mkdir -p "$@" && cd "$_"; }
mkt() { cd "$(mktemp -d)" && pwd; }
cdl() { cd "$1" && ls -l; }

sc system status -q
EOF
