source "$SC_LIBS"
core::init
process::usage "sc http get <url>" 1 1 "$@"
process::require HTTP_CLIENT "curl" "wget" "python"

URL="$1"

case "$HTTP_CLIENT" in
  curl)
    curl --fail --show-error --location "$URL"
    ;;
  wget)
    wget --output-document=- "$URL"
    ;;
  python)
    python - "$URL" <<'PY'
from urllib.request import urlopen
from sys import stdout, argv

with urlopen(argv[1]) as u:
    while (buf := u.read(4048)):
        stdout.buffer.write(buf)
PY
    ;;
esac
