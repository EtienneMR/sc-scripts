PROJECTS_DIR="${SC_PROJECTS_DIR:-$HOME/projects}"

projects::find() {
  local project_dir
  if [ "$#" -eq 1 ]; then
    project_dir="$PROJECTS_DIR/$1"
    [ -d "$project_dir/.git" ] || log::die "Project not found: $1"
  else
    project_dir="$(pwd)"
    while [ "$project_dir" != "$PROJECTS_DIR" ] && [ "$project_dir" != "/" ]; do
      [ "$(dirname "$project_dir")" = "$PROJECTS_DIR" ] && break
      project_dir="$(dirname "$project_dir")"
    done

    [ -d "$project_dir/.git" ] || log::die "Not inside a project"
  fi

  echo "$project_dir"
}
