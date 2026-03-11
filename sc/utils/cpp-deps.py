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
    """Return ordered list of .cpp files to compile alongside entry."""
    entry = entry.resolve()
    visited = {entry}  # never re-visit, never emit the entry itself
    queue = deque([entry])
    deps = []

    while queue:
        current = queue.popleft()
        for header in local_includes(current):
            if header in visited:
                continue
            visited.add(header)
            # If the header has a sibling .cpp, it needs to be compiled too
            sibling = header.with_suffix(".cpp")
            if sibling.exists() and sibling not in visited:
                visited.add(sibling)
                deps.append(sibling)
                queue.append(sibling)  # recurse: sibling may include more headers
            # Traverse the header itself for transitive includes
            queue.append(header)

    return deps


def main():
    if len(sys.argv) != 2:
        print("usage: cpp-deps.py <file.cpp>", file=sys.stderr)
        sys.exit(1)

    entry = Path(sys.argv[1])
    if not entry.exists():
        print(f"error: file not found: {entry}", file=sys.stderr)
        sys.exit(1)

    for dep in cpp_deps(entry):
        print(dep)


if __name__ == "__main__":
    main()
