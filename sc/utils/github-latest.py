import sys
import json
import urllib.request


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: github_latest.py <owner/repo>", file=sys.stderr)
        sys.exit(1)
    url = f"https://api.github.com/repos/{sys.argv[1]}/releases/latest"
    with urllib.request.urlopen(url) as resp:
        print(json.loads(resp.read())["tag_name"])
