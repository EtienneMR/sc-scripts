# sc:complete + compgen -fd -- "$COMP_CUR"
source "$SC_LIBS"
core::init
process::usage "sc code format [files...]" 0 + "$@"

_format_py() { process::py_run ruff format --quiet "$@" || process::py_run black --quiet "$@" || log::warn "No formatter for .py (install ruff or black)"; }

_format_js() { process::js_run prettier --write --log-level=warn "$@" || log::warn "No formatter for .js (install prettier)"; }
_format_ts() { _format_js "$@"; }
_format_jsx() { _format_js "$@"; }
_format_tsx() { _format_js "$@"; }
_format_css() { _format_js "$@"; }
_format_html() { _format_js "$@"; }
_format_json() { _format_js "$@"; }
_format_yaml() { _format_js "$@"; }
_format_yml() { _format_js "$@"; }
_format_md() { _format_js "$@"; }

_format_c() { process::py_run clang-format -i "$@" || log::warn "No formatter for .c (install clang-format)"; }
_format_cpp() { _format_c "$@"; }
_format_h() { _format_c "$@"; }
_format_hpp() { _format_c "$@"; }

_format_bash() { process::exists shfmt && shfmt --write --indent 2 --simplify --case-indent "$@" || log::warn "No formatter for .bash (install shfmt)"; }
_format_sh() { _format_bash "$@"; }

_format_rs() { process::exists rustfmt && rustfmt "$@" || log::warn "No formatter for .rs (install rustfmt)"; }
_format_go() { process::exists gofmt && gofmt -w "$@" || log::warn "No formatter for .go (install gofmt)"; }
_format_lua() { process::exists stylua && stylua "$@" || log::warn "No formatter for .lua (install stylua)"; }

fs::each_ext "Formatting" _format "$@"
