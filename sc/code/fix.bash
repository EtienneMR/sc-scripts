source "$SC_LIBS"
core::init

_fix_py() { process::py_run ruff check --fix --quiet "$@" || log::warn "no fixer for .py (install ruff)"; }

_fix_js() { process::js_run eslint --fix "$@" || log::warn "no fixer for .js (install eslint)"; }
_fix_ts() { _fix_js "$@"; }
_fix_jsx() { _fix_js "$@"; }
_fix_tsx() { _fix_js "$@"; }

_fix_go() { process::py_run go fix "$@" || log::warn "no fixer for .go (install go)"; }
_fix_rs() { process::py_run cargo fix --edition-idioms --allow-dirty --allow-staged "$@" 2>/dev/null || log::warn "no fixer for .rs (install cargo)"; }

fs::each_ext "Fixing" _fix "$@"
"$SC" code format "$@"
