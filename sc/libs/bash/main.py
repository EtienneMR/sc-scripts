from pathlib import Path

core = Path(__file__).resolve().with_name("core.bash").as_posix()

if __name__ == "__main__":
    print(core)
