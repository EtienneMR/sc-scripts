import os
import signal
import subprocess
import sys
from pathlib import Path

CLI_MAIN = Path(__file__).with_stem("__main__").resolve()
CLI_LIBS = CLI_MAIN.parent / "_libs" / "core.bash"
INTERPRETERS = {
    ".py": sys.executable,
    ".bash": "bash",
}

HELP_FLAGS = {"-h", "--help"}


def scan(directory: Path) -> dict:
    """Recursively build {name: path_or_subtree} from the sc package dir."""
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
        return tree, tokens
    if isinstance(node, Path):
        return node, tokens[1:]
    child, rest = resolve(tokens[1:], node)
    return (child, rest) if child is not None else (node, tokens[1:])


def custom_completions(script: Path, arg: int, partial: str) -> list:
    """Call a script's custom completion handler if it defines one."""
    marker = "# sc:complete "
    try:
        with open(script) as fh:
            for line in fh:
                line = line.rstrip("\n")
                if not line.startswith("#"):
                    break
                if not line.startswith(marker):
                    continue
                line = line.removeprefix(marker)
                completion_arg, line = line.split(" ", 1)
                if completion_arg not in {"+", str(arg)}:
                    continue

                env = {**os.environ, "COMP_CUR": partial}
                result = subprocess.run(
                    ["bash", "-c", line],
                    capture_output=True,
                    text=True,
                    env=env,
                )
                results = [
                    w for w in result.stdout.splitlines() if w.startswith(partial)
                ]
                return [w + "/" if os.path.isdir(w) else w for w in results]
    except (OSError, UnicodeDecodeError):
        pass
    return []


def completions(tokens: list, tree: dict) -> list:
    """Return valid next tokens given already-typed tokens (last may be partial)."""
    *prefix, current = tokens

    node, rest = resolve(prefix, tree)
    if node is None:
        return []

    if isinstance(node, Path):
        return custom_completions(node, len(rest), current)

    if not rest:
        return [k for k in node if k.startswith(current)]

    return []


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


def usage_group(tree: dict, prefix: str = ""):
    """Print help for a command group (directory node)."""
    cmd = f"sc {prefix}".strip()
    print(f"Usage: {cmd} <command> [args...]\n")
    print_tree(tree)


def main():
    tree = scan(CLI_MAIN.parent)
    args = sys.argv[1:]

    if args and args[0] == "--complete":
        found = completions(args[1:], tree)
        if found:
            print("\n".join(set(found)))
        return 0

    help_requested = any(a in HELP_FLAGS for a in args)
    clean_args = [a for a in args if a not in HELP_FLAGS]

    if not clean_args:
        usage_group(tree)
        return 0

    node, remaining = resolve(clean_args, tree)

    if node is None:
        usage_group(tree)
        return 1

    if isinstance(node, dict):
        error_index = -len(remaining)
        if error_index != 0:
            print(
                f"Error: unknown command '{clean_args[error_index]}'", file=sys.stderr
            )
        prefix = " ".join(clean_args[:error_index])
        usage_group(node, prefix)
        return 0 if help_requested and error_index == 0 else 1

    if help_requested:
        remaining += ["--help"]

    return run(node, remaining)
