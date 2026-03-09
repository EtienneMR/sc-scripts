import sys, os, time

if __name__ == "__main__":
    file = sys.argv[1]
    mtime = os.path.getmtime(file)
    while os.path.getmtime(file) == mtime:
        time.sleep(0.5)
