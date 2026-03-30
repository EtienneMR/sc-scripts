export LOG_DEBUG=1
if [ "$#" -gt 0 ]; then
  exec "$SC" "$@"
else
  log::info "Using debug mode"
  exec "$SHELL"
fi
