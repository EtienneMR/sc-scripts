import sys
import re
from pathlib import Path
from collections import deque

INCLUDE_RE = re.compile(r'#\s*include\s+"([^"]+)"')


def local_includes(file: Path) -> list:
    """Return paths of all locally-quoted includes in file that exist on disk."""
    try:
        text = file.read_text(errors="replace")
    except OSError:
        return []
    result = []
    for match in INCLUDE_RE.finditer(text):
        candidate = (file.parent / match.group(1)).resolve()
        if candidate.exists():
            result.append(candidate)
    return result


def cpp_deps(entry: Path) -> list:
    """Return ordered list of .cpp dependency files to compile alongside entry."""
    entry = entry.resolve()
    visited = {entry}
    queue = deque([entry])
    deps = []

    while queue:
        current = queue.popleft()
        for header in local_includes(current):
            if header in visited:
                continue
            visited.add(header)
            sibling = header.with_suffix(".cpp")
            if sibling.exists() and sibling not in visited:
                visited.add(sibling)
                deps.append(sibling)
            queue.append(header)

    return deps


def to_obj(path: Path, cwd: Path) -> Path:
    """Convert an absolute .cpp path to a build/relative.o path."""
    try:
        rel = path.relative_to(cwd)
    except ValueError:
        rel = path
    return Path("build") / rel.with_suffix(".o")


def main():
    args = sys.argv[1:]
    make_objs = "--make-objs" in args
    args = [a for a in args if not a.startswith("--")]

    if len(args) != 1:
        print("Usage: cpp-deps.py [--make-objs] <file.cpp>", file=sys.stderr)
        sys.exit(1)

    entry = Path(args[0])
    if not entry.exists():
        print(f"Error: file not found: {entry}", file=sys.stderr)
        sys.exit(1)

    deps = cpp_deps(entry)
    cwd = Path.cwd()

    if make_objs:
        print(to_obj(entry.resolve(), cwd))
        for dep in deps:
            print(to_obj(dep, cwd))
    else:
        for dep in deps:
            print(dep)


if __name__ == "__main__":
    main()
