import sys
import os
import time


def poll_change(file: str) -> None:
    start_mtime = current_mtime = os.path.getmtime(file)
    delay = 0.5

    while start_mtime == current_mtime:
        time.sleep(delay)
        delay = 1 + delay / 2
        current_mtime = os.path.getmtime(file)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <file_to_watch>")
        sys.exit(1)

    if not os.path.isfile(sys.argv[0]):
        sys.exit(f"File not found: {sys.argv[0]}")

    try:
        poll_change(sys.argv[1])
    except KeyboardInterrupt:
        sys.exit(130)
