import os
import signal
import sys
from pathlib import Path

CLI_MAIN = Path(__file__).with_stem("__main__").resolve()
CLI_LIBS = CLI_MAIN.parent / "_libs" / "core.bash"
INTERPRETERS = {
    ".py": sys.executable,
    ".bash": "bash",
}


def scan(directory: Path) -> dict:
    """Recursively build {name: path_or_subtree} from bin/."""
    tree = {}
    for entry in sorted(directory.iterdir()):
        if entry.name.startswith(".") or entry.name.startswith("_"):
            continue
        if entry.is_file():
            tree[entry.stem] = entry
        elif entry.is_dir():
            sub = scan(entry)
            if sub:
                tree[entry.name] = sub
    return tree


def resolve(tokens: list, tree: dict) -> tuple:
    """Walk tokens into tree. Returns (script_path, remaining_args) or (subtree, [])."""
    if not tokens:
        return tree, []
    node = tree.get(tokens[0])
    if node is None:
        return None, tokens
    if isinstance(node, Path):
        return node, tokens[1:]
    child, rest = resolve(tokens[1:], node)
    return (child, rest) if child is not None else (node, tokens[1:])


def completions(tokens: list, tree: dict) -> list:
    """Return valid next tokens given already-typed tokens (last may be partial)."""
    *prefix, current = tokens

    node, rest = resolve(prefix, tree)
    if node is None or rest:
        return []

    return [k for k in node if k.startswith(current)]


def run(script: Path, args: list) -> int:
    cmd = [
        *(
            [interpreter]
            if (interpreter := INTERPRETERS.get(script.suffix.lower()))
            else []
        ),
        script.as_posix(),
        *args,
    ]
    env = {
        **os.environ,
        "SC": CLI_MAIN.as_posix(),
        "SC_ROOT": CLI_MAIN.parent.parent.as_posix(),
        "SC_LIBS": CLI_LIBS.as_posix(),
    }
    try:
        signal.signal(signal.SIGINT, signal.SIG_DFL)
        os.execvpe(cmd[0], cmd, env)
    except FileNotFoundError:
        sys.exit(f"error: interpreter not found for {script.name}")


def print_tree(tree: dict, indent=""):
    items = list(tree.items())
    for i, (name, node) in enumerate(items):
        branch = "└── " if i == len(items) - 1 else "├── "
        label = f"{name}  [{node.suffix}]" if isinstance(node, Path) else f"{name}/"
        print(f"{indent}{branch}{label}")
        if isinstance(node, dict):
            print_tree(node, indent + ("    " if i == len(items) - 1 else "│   "))


def usage(tree: dict, prefix=""):
    cmd = f"sc {prefix}".strip()
    print(f"Usage: {cmd} <command> [args...]\n")
    print_tree(tree)


def main():
    tree = scan(CLI_MAIN.parent)
    args = sys.argv[1:]

    if not args or args[0] in ("-h", "--help"):
        usage(tree)
        return 0

    if args[0] == "--complete":
        found = completions(args[1:], tree)
        if found:
            print("\n".join(found))
        return 0

    node, remaining = resolve(args, tree)

    if node is None:
        print(f"error: unknown command '{args[0]}'\n", file=sys.stderr)
        usage(tree)
        return 1

    if isinstance(node, dict):
        usage(node, " ".join(args[: args.index(args[0]) + 1]))
        return 1

    return run(node, remaining)
