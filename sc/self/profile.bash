source "$SC_LIBS"

SC_MAIN="$SC_ROOT/sc/__main__.py"

_profile::bash() {
  cat <<EOF
_sc_complete() {
    local cur raw line
    local -a before suggestions
    COMPREPLY=()
    cur="\${COMP_WORDS[COMP_CWORD]}"
    before=("\${COMP_WORDS[@]:1:COMP_CWORD-1}")
    if [[ \${#before[@]} -eq 0 ]]; then
        raw=\$( '$SC_MAIN' --complete "\$cur" 2>/dev/null )
    else
        raw=\$( '$SC_MAIN' --complete "\${before[@]}" "\$cur" 2>/dev/null )
    fi
    while IFS= read -r line; do [[ -n "\$line" ]] && suggestions+=("\$line"); done <<< "\$raw"
    COMPREPLY=( \$(compgen -W "\${suggestions[*]}" -- "\$cur") )
}
complete -F _sc_complete sc
EOF
}

_profile::zsh() {
  cat <<EOF
_sc_complete() {
    local -a before suggestions
    before=("\${words[@]:1:\$#words-2}")
    local cur="\${words[\$#words]}"
    if [[ \${#before[@]} -eq 0 ]]; then
        suggestions=( \$('$SC_MAIN' --complete "\$cur" 2>/dev/null) )
    else
        suggestions=( \$('$SC_MAIN' --complete "\${before[@]}" "\$cur" 2>/dev/null) )
    fi
    compadd -a suggestions
}
compdef _sc_complete sc
EOF
}

_profile::fish() {
  cat <<EOF
function __fish_sc_complete
    set -l tokens (commandline -opc); set -e tokens[1]
    '$SC_MAIN' --complete \$tokens (commandline -ct) 2>/dev/null
end
complete -c sc -f -a '(__fish_sc_complete)'
EOF
}

case "$(process::detect_shell)" in
  bash) _profile::bash ;;
  zsh) _profile::zsh ;;
  fish) _profile::fish ;;
  *) log::warn "unrecognized shell: completion not installed" ;;
esac
