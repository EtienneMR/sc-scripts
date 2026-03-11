#!/usr/bin/env python3

import sys

if __package__ is None:
    import runpy
    from pathlib import Path

    package_root = Path(__file__).resolve().parent.parent.as_posix()
    sys.path.insert(0, package_root)

    runpy.run_module("sc", run_name="__main__")
    sys.exit(1)

from ._cli import main


try:
    sys.exit(main())
except KeyboardInterrupt:
    sys.exit(130)
