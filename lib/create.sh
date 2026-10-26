# shellcheck shell=bash

nwe_herdr() {
  "${HERDR_BIN_PATH:-herdr}" "$@"
}

nwe_create_named_workspace() {
  local name="$1"
  if [ -n "$name" ]; then
    nwe_herdr workspace create --label "$name" --focus >/dev/null
  else
    nwe_herdr workspace create --focus >/dev/null
  fi
}

nwe_create_worktree_workspace() {
  local repo="$1" branch base label
  {
    IFS= read -r branch
    IFS= read -r base
    IFS= read -r label
  } <<EOT
$2
EOT
  if [ -n "$base" ]; then
    nwe_herdr worktree create --cwd "$repo" --branch "$branch" --base "$base" --label "$label" --focus >/dev/null
  else
    nwe_herdr worktree create --cwd "$repo" --branch "$branch" --label "$label" --focus >/dev/null
  fi
}
