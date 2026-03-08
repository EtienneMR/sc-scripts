import os, sys, subprocess
from pathlib import Path

from sc.utils.detect_shell import detect_shell


CLI_NAME = "sc"
CLI_MAIN = Path(__file__).with_stem("__main__").resolve()
INTERPRETERS = {
    ".py": sys.executable,
    ".sh": "bash",
    ".bash": "bash",
    ".zsh": "zsh",
    ".fish": "fish",
}

SHELL_SCRIPTS = {
    "bash": f"""\
_{CLI_NAME}_complete() {{
    local cur raw line
    local -a before suggestions
    COMPREPLY=()
    cur="${{COMP_WORDS[COMP_CWORD]}}"
    before=("${{COMP_WORDS[@]:1:COMP_CWORD-1}}")
    if [[ ${{#before[@]}} -eq 0 ]]; then
        raw=$( '{CLI_MAIN.as_posix()}' --complete "$cur" 2>/dev/null )
    else
        raw=$( '{CLI_MAIN.as_posix()}' --complete "${{before[@]}}" "$cur" 2>/dev/null )
    fi
    while IFS= read -r line; do [[ -n "$line" ]] && suggestions+=("$line"); done <<< "$raw"
    COMPREPLY=( $(compgen -W "${{suggestions[*]}}" -- "$cur") )
}}
complete -F _{CLI_NAME}_complete {CLI_NAME}\
""",
    "zsh": f"""\
_{CLI_NAME}_complete() {{
    local -a before suggestions
    before=("${{words[@]:1:$#words-2}}")
    local cur="${{words[$#words]}}"
    if [[ ${{#before[@]}} -eq 0 ]]; then
        suggestions=( $('{CLI_MAIN.as_posix()}' --complete "$cur" 2>/dev/null) )
    else
        suggestions=( $('{CLI_MAIN.as_posix()}' --complete "${{before[@]}}" "$cur" 2>/dev/null) )
    fi
    compadd -a suggestions
}}
compdef _{CLI_NAME}_complete {CLI_NAME}\
""",
    "fish": f"""\
function __fish_{CLI_NAME}_complete
    set -l tokens (commandline -opc); set -e tokens[1]
    '{CLI_MAIN.as_posix()}' --complete $tokens (commandline -ct) 2>/dev/null
end
complete -c {CLI_MAIN.as_posix()} -f -a '(__fish_{CLI_NAME}_complete)'\
""",
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
    interpreter = INTERPRETERS.get(script.suffix.lower())
    cmd = ([interpreter, str(script)] if interpreter else [str(script)]) + args
    try:
        return subprocess.run(
            cmd,
            env={
                **os.environ,
                "SC": CLI_MAIN.as_posix(),
                "SC_ROOT": CLI_MAIN.parent.parent.as_posix(),
                "SC_SCRIPT": script.stem,
            },
        ).returncode
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
    cmd = f"{CLI_NAME} {prefix}".strip()
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

    if args[0] == "--install-completion":
        shell = detect_shell()
        script = SHELL_SCRIPTS.get(shell)
        if script is None:
            sys.exit(
                f"error: unknown shell '{shell}'. Choose: {', '.join(SHELL_SCRIPTS.keys())}"
            )
        print(script)
        return 0

    node, remaining = resolve(args, tree)

    if node is None:
        print(f"error: unknown command '{args[0]}'\n", file=sys.stderr)
        usage(tree)
        return 1

    if isinstance(node, dict):
        main = node.get("main")
        if isinstance(main, Path):
            node = main
        else:
            usage(node, " ".join(args[: args.index(args[0]) + 1]))
            return 1

    return run(node, remaining)
