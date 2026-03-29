# sc:complete + compgen -f -X '!*.cpp' -- "$COMP_CUR" ; compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc cpp makefile [FILE.cpp...]" 0 + "$@"
process::require COMPILER "clang++" "g++"

log::debug "Opening fd 3"
2>/dev/null >&3 || exec 3>&1

MAKEFILE="$(pwd)/Makefile"

log::info "Writing base Makefile template" | log::overwrite >&3
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
		echo "  Running test $$bin"; \
		if ! ./$$bin; then \
			failed="$$failed $$bin"; \
		fi; \
	done; \
	if [ -n "$$failed" ]; then \
		echo "  Failed tests: $$failed"; \
		exit 1; \
	else \
		echo "  All tests passed"; \
	fi

clean:
	rm -rf build/ dist/
MAKE
) | "$SC" utils append "$MAKEFILE" "# SC CPP BASE"

if [ "$#" = 0 ]; then
  fs::find TARGETS . "main.cpp" "*.main.cpp" "*-main.cpp" "test.cpp" "*.test.cpp" "*-test.cpp"
else
  TARGETS="$@"
fi

for FILE in "${TARGETS[@]}"; do
  [ -f "$FILE" ] || log::die "FILE not found: $FILE"

  STEM="$(basename "$FILE" .cpp)"
  KIND="${STEM##*.}"
  NAME="$(realpath --relative-to="$(pwd)" "${FILE%.*}")"
  TARGET="dist/$NAME"

  case "$KIND" in
    "main") GROUP="binaries" ;;
    "test") GROUP="tests" ;;
    *) GROUP="all" ;;
  esac

  log::info "Updating target $NAME" | log::overwrite >&3

  mapfile -t OBJS < <("$SC" utils cpp-deps --make-objs "$FILE") ||
    log::die "Dependency resolution failed for $FILE"

  "$SC" utils append "$MAKEFILE" "# SC CPP TARGET $NAME" <<MAKE
$TARGET: ${OBJS[*]}
$GROUP: $TARGET
MAKE
done

echo >&3
