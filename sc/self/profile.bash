source "$SC_LIBS"
core::init
process::usage "sc self profile" 0 0 "$@"

_profile::bash() {
  cat <<'EOF'
_sc_complete() {
    mapfile -t COMPREPLY < <(sc --complete "${COMP_WORDS[@]:1:COMP_CWORD}" 2>/dev/null)
    [[ ${#COMPREPLY[@]} -eq 1 && "${COMPREPLY[0]}" == */ ]] && compopt -o nospace
}
complete -F _sc_complete sc
EOF
}

_profile::zsh() {
  cat <<'EOF'
_sc_complete() {
    local -a suggestions
    mapfile -t suggestions < <(sc --complete "${COMP_WORDS[@]}" 2>/dev/null)
    compadd -a suggestions
}
compdef _sc_complete sc
EOF
}

_profile::fish() {
  cat <<'EOF'
function __fish_sc_complete
    set -l tokens (commandline -opc); set -e tokens[1]
    sc --complete $tokens (commandline -ct) 2>/dev/null
end
complete -c sc -f -a '(__fish_sc_complete)'
EOF
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
      echo "alias $name='sc $sc_cmd'"
    done <"$script"
  done
}

_profile::aliases
case "$(process::detect_shell)" in
  bash) _profile::bash ;;
  zsh) _profile::zsh ;;
  fish) _profile::fish ;;
  *) log::warn "Unrecognized shell: completion not installed" ;;
esac
