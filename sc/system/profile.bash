source "$SC_LIBS"
core::init
process::usage "sc system profile" 0 0 "$@"

cat <<'EOF'
mkcd() { mkdir -p "$@" && cd "$_"; }
cdl() { cd "$1" && ls -lA; }
EOF

echo -n "export EDITOR="
if process::exists codium; then
  echo '"codium --wait"'
elif process::exists code; then
  echo '"code --wait"'
else
  echo '"sc web codium"'
fi

echo 'sc system status -q'
