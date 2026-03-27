# sc:complete + compgen -f -X '!*.cpp' -- "$COMP_CUR" ; compgen -d -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc cpp makefile [file.cpp...]" 0 + "$@"
process::require COMPILER "clang++" "g++"

log::debug "Opening fd 3"
2>/dev/null >&3 || exec 3>&1

MAKEFILE="$(pwd)/Makefile"

if [ ! -f "$MAKEFILE" ]; then
  log::info "Writing base Makefile template" | log::overwrite >&3
  cat >"$MAKEFILE" <<MAKE
CXX      = $COMPILER
CXXFLAGS = -std=c++11 -Wall -Wextra -fcolor-diagnostics

DEPS := \$(shell find build -name '*.d' 2>/dev/null)
-include \$(DEPS)

all:
.PHONY: all clean

build/%.o: %.cpp
	@mkdir -p \$(@D)
	\$(CXX) \$(CXXFLAGS) -MMD -MP -c $< -o \$@

dist/%:
	@mkdir -p \$(@D)
	\$(CXX) \$(CXXFLAGS) $^ -o \$@

clean:
	rm -rf build/ dist/
MAKE
fi

for FILE in "$@"; do
  [ -f "$FILE" ] || log::die "File not found: $FILE"

  STEM="$(basename "${FILE%.cpp}")"
  log::info "Updating target $STEM" | log::overwrite >&3

  mapfile -t OBJS < <("$SC" utils cpp-deps --make-objs "$FILE") ||
    log::die "Dependency resolution failed for $FILE"

  TARGET="dist/$STEM"

  "$SC" utils append "$MAKEFILE" "# SC CPP TARGET $STEM" <<MAKE
$TARGET: ${OBJS[*]}
all: $TARGET
MAKE
done

echo >&3
