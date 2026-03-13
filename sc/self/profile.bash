source "$SC_LIBS"

_profile::bash() {
  cat <<'EOF'
_sc_complete() {
    local cur raw line
    local -a before suggestions
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    before=("${COMP_WORDS[@]:1:COMP_CWORD-1}")
    if [[ ${#before[@]} -eq 0 ]]; then
        raw=$( sc --complete "$cur" 2>/dev/null )
    else
        raw=$( sc --complete "${before[@]}" "$cur" 2>/dev/null )
    fi
    while IFS= read -r line; do [[ -n "$line" ]] && suggestions+=("$line"); done <<< "$raw"
    COMPREPLY=( $(compgen -W "${suggestions[*]}" -- "$cur") )
}
complete -F _sc_complete sc
EOF
}

_profile::zsh() {
  cat <<'EOF'
_sc_complete() {
    local -a before suggestions
    before=("${words[@]:1:$#words-2}")
    local cur="${words[$#words]}"
    if [[ ${#before[@]} -eq 0 ]]; then
        suggestions=( $(sc --complete "$cur" 2>/dev/null) )
    else
        suggestions=( $(sc --complete "${before[@]}" "$cur" 2>/dev/null) )
    fi
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
  local script line name sc_cmd
  while IFS= read -r script; do          # for each script
    while IFS= read -r line; do          # read lines
      [[ "$line" == \#* ]] || break      # stop at first non-comment
      [[ "$line" =~ ^#\ sc:alias\ ([^[:space:]]+) ]] || continue
      name="${BASH_REMATCH[1]}"
      sc_cmd="$(realpath --relative-to="$SC_ROOT/sc" "$script" | sed 's/\.[^.]*$//' | tr '/' ' ')"
      echo "alias $name='sc $sc_cmd'"
    done < "$script"
  done < <(find "$SC_ROOT/sc" -type f \( -name "*.bash" -o -name "*.py" \) | sort)
}

_profile::custom-aliases() {
  cat <<'EOF'
mkcd() { mkdir -p "$@" && cd "$_"; }
mkt() { cd "$(mktemp -d)" && pwd; }
cdl() { cd "$1" && ls -l; }
EOF
}

_profile::aliases
_profile::custom-aliases
case "$(process::detect_shell)" in
  bash) _profile::bash ;;
  zsh) _profile::zsh ;;
  fish) _profile::fish ;;
  *) log::warn "Unrecognized shell: completion not installed" ;;
esac
