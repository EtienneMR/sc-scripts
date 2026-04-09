# sc:complete * compgen -fd -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc code tidy [files...]" 0 + "$@"

_tidy_py() { process::py_run ruff check --fix --quiet "$@" || log::warn "No tidier for .py (install ruff)"; }

_tidy_js() { process::js_run eslint --fix "$@" || log::warn "No tidier for .js (install eslint)"; }
_tidy_ts() { _tidy_js "$@"; }
_tidy_jsx() { _tidy_js "$@"; }
_tidy_tsx() { _tidy_js "$@"; }

_tidy_go() { process::exists go && go fix "$@" || log::warn "No tidier for .go (install go)"; }
_tidy_rs() {
    if process::exists cargo; then
        cargo fix --edition-idioms --allow-dirty --allow-staged "$@" 2>/dev/null || true
    else
        log::warn "No tidier for .rs (install cargo)"
    fi
}

fs::each_ext "Tidying" _tidy "$@"
"$SC" code format "$@"
