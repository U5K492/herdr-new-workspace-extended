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
  local repo="$1" branch="$2" base="$3" label="$4"
  nwe_herdr worktree create --cwd "$repo" --branch "$branch" --base "$base" --label "$label" --focus >/dev/null
}
