# sc:complete + compgen -f -X '!*.cpp' -- "$COMP_CUR" ; compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc cpp makefile [file.cpp...]" 0 + "$@"
process::require COMPILER "clang++" "g++"

MAKEFILE="$(pwd)/Makefile"

log::status "Writing base Makefile template"
(
  echo "CXX      := $COMPILER"

  echo -n 'CXXFLAGS := $(strip $(CXXFLAGS) '
  if [ -f compile_flags.txt ]; then
    echo -n '$(shell tr "\n" " " < compile_flags.txt)'
  else
    echo -n "-std=c++11 -Wall -Wextra"
  fi
  echo ")"

  cat <<'MAKE'

-include $(shell find build -name '*.d' 2>/dev/null)

all: binaries tests
.PHONY: all binaries tests clean

build/%.o: %.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

dist/%:
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $^ -o $@

binaries:
tests:
	@failed=""; \
	for bin in $^; do \
		printf "  %-50s" "$$bin"; \
		out="$$(mktemp)"; \
		if "$$bin" >"$$out" 2>&1; then \
			printf "ok\n"; \
		else \
			printf "FAILED (%d)\n" "$$?"; \
			cat "$$out" >&2; \
			failed="$$failed\n  $$bin"; \
		fi; \
		rm -f "$$out"; \
	done; \
	if [ -n "$$failed" ]; then \
		printf "Failed tests:%b\n" "$$failed" >&2; \
		exit 1; \
	else \
		echo "All tests passed"; \
	fi

clean:
	rm -rf build/ dist/
MAKE
) | "$SC" utils append "$MAKEFILE" "# SC CPP BASE"

if [ "$#" = 0 ]; then
  fs::find TARGETS . "main.cpp" "*.main.cpp" "*-main.cpp" "test.cpp" "*.test.cpp" "*-test.cpp"
else
  TARGETS=("$@")
fi

for FILE in "${TARGETS[@]}"; do
  [ -f "$FILE" ] || log::die "File not found: $FILE"

  STEM="$(basename "$FILE" .cpp)"
  KIND="${STEM##*.}"
  NAME="$(realpath --relative-to="$(pwd)" "${FILE%.*}")"
  TARGET="dist/$NAME"

  case "$KIND" in
    "main") GROUP="binaries" ;;
    "test") GROUP="tests" ;;
    *) GROUP="all" ;;
  esac

  log::status "Updating target $NAME"

  mapfile -t OBJS < <("$SC" utils cpp-deps --make-objs "$FILE") ||
    log::die "Dependency resolution failed for $FILE"

  "$SC" utils append "$MAKEFILE" "# SC CPP TARGET $NAME" <<MAKE
$TARGET: ${OBJS[*]}
$GROUP: $TARGET
MAKE
done
