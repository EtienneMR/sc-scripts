import os
import sys
import tempfile
from pathlib import Path


def append(file: str, marker: str, content: str) -> None:
    """Insert or replace a marked block in a file.

    The block is delimited by:
        <marker> START
        ...
        <marker> END

    If the markers are found, the content between them is replaced.
    If not found, the block is appended to the end of the file.
    If content is empty, remove the block.
    The file is written atomically (temp file + rename).

    Usage from bash:
        "$SC" fs append ~/.bashrc "# SC PROFILE" "the content to add"
    """
    path = Path(file).expanduser()
    start_marker = f"{marker} START"
    end_marker   = f"{marker} END"
    block = f"{start_marker}\n{content}\n{end_marker}\n" if content else ""

    if path.exists():
        original = path.read_text()
    elif not content:
        return
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        original = ""

    start = original.find(start_marker)
    end   = original.find(end_marker)

    if start != -1 and end != -1 and start < end:
        # Replace existing block, preserving everything outside it
        new_text = original[:start] + block + original[end + len(end_marker) + 1:]
    else:
        # Append — ensure a single blank line separator
        new_text = original.rstrip("\n") + ("\n\n" if original else "") + block

    _write_atomic(path, new_text)


def _write_atomic(path: Path, content: str) -> None:
    """Write via a temp file in the same directory, then rename.
    Rename is atomic on POSIX — the file is never left half-written.
    """
    fd, tmp = tempfile.mkstemp(dir=path.parent)
    try:
        with os.fdopen(fd, "w") as f:
            f.write(content)
        os.replace(tmp, path)
    except Exception:
        os.unlink(tmp)
        raise


if __name__ == "__main__":
    if len(sys.argv) == 4:
        content = sys.argv[3]
    elif len(sys.argv) == 3:
        content = sys.stdin.read().removesuffix("\n")
    else:
        print("usage: append.py <file> <marker> [content]", file=sys.stderr)
        print("       content may also be piped via stdin", file=sys.stderr)
        sys.exit(1)
    append(sys.argv[1], sys.argv[2], content)
