from os import environ, path


def detect_shell() -> str:
    return path.basename(environ.get("SHELL", ""))


if __name__ == "__main__":
    print(detect_shell())
