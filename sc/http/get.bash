source "$SC_LIBS"
core::init
process::usage "sc http get <url>" 1 1 "$@"
process::require HTTP_CLIENT "curl" "wget" "python3"

URL="$1"

case "$HTTP_CLIENT" in
  curl)
    curl --fail --show-error --location "$URL"
    ;;
  wget)
    wget --output-document=- "$URL"
    ;;
  python3)
    python3 - "$URL" <<'PY'
from urllib.request import urlopen
from sys import stdout, argv

with urlopen(argv[1]) as u:
    while (buf := u.read(4048)):
        stdout.buffer.write(buf)
PY
    ;;
esac
