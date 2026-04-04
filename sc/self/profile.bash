source "$SC_LIBS"
core::init
process::usage "sc self profile" 0 0 "$@"

_profile::bash() {
  cat <<'BASH'
_sc_complete() {
    mapfile -t COMPREPLY < <(sc --complete "$@" "${COMP_WORDS[@]:1:COMP_CWORD}")
    [[ ${#COMPREPLY[@]} -eq 1 && "${COMPREPLY[0]}" == */ ]] && compopt -o nospace
}
_sc_alias() {
    local name="$1"
    shift

    [ "$#" -gt 0 ] && alias "$name=sc $*"
    eval "
_sc_complete_$name() { _sc_complete $*; }
complete -F _sc_complete_$name $name
"
}
_sc_alias sc
BASH
}

_profile::zsh() {
  cat <<'ZSH'
_sc_complete() {
    local -a completions
    completions=("${(@f)$(sc --complete "$@" "${words[@]:1:$((CURRENT-1))}")}")
    if [[ ${#completions[@]} -eq 1 && "${completions[0]}" == */ ]]; then
        compadd -S '' -- "${completions[@]}"
    else
        compadd -- "${completions[@]}"
    fi
}
_sc_alias() {
    local name="$1"
    shift
    [[ "$#" -gt 0 ]] && alias "$name=sc $*"
    local args="$*"
    eval "
_sc_complete_${name}() { _sc_complete ${args}; }
compdef _sc_complete_${name} ${name}
"
}
_sc_alias sc
ZSH
}

_profile::aliases() {
  local all_scripts
  fs::find all_scripts "$SC_ROOT/sc"

  local line name sc_cmd
  for script in "${all_scripts[@]}"; do
    while IFS= read -r line; do
      [[ $line == \#* ]] || break
      [[ $line =~ ^#\ sc:alias\ ([^[:space:]]+) ]] || continue
      name="${BASH_REMATCH[1]}"
      sc_cmd="$(realpath --relative-to="$SC_ROOT/sc" "$script" | sed 's/\.[^.]*$//' | tr '/' ' ')"
      echo "_sc_alias $name $sc_cmd"
    done <"$script"
  done
}

case "$(process::detect_shell)" in
  bash) _profile::bash ;;
  zsh) _profile::zsh ;;
  *)
    log::warn "Unrecognized shell: completion not installed"
    exit 0
    ;;
esac
_profile::aliases
