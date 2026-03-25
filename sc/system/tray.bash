source "$SC_LIBS"
core::init
process::usage "sc system tray" 0 0 "$@"
process::require yad

ICON_WARN="dialog-warning"
ICON_ERROR="dialog-error"

_status_icon() {
  local output="$1"
  echo "$output" | grep -q "✖" && echo "$ICON_ERROR" && return
  echo "$ICON_WARN"
}

_show() {
  local output="$1"

  GDK_BACKEND=x11 yad --notification \
    --image="$(_status_icon "$output")" \
    --menu="Refresh ! quit|Update ! konsole -e sc system update
|Reboot ! konsole -e sudo reboot" \
    --command="menu"
}

yad_pid=""

while :; do
  output="$("$SC" system status -q 2>&1)"

  [ -n "$yad_pid" ] && kill "$yad_pid" 2>/dev/null || true
  yad_pid=""

  if [ -n "$output" ]; then
    _show "$output" &
    yad_pid=$!
  fi

  sleep 3600 &
  sleep_pid=$!

  process::wait_any_pid $yad_pid $sleep_pid
done
