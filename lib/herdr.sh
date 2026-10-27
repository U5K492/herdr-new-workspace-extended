# shellcheck shell=bash

nwe_herdr() {
  "${HERDR_BIN_PATH:-herdr}" "$@"
}

nwe_context_cwd() {
  printf '%s' "${NWE_CONTEXT_JSON:-}" | jq -r '.focused_pane_cwd // .workspace_cwd // empty'
}

nwe_create_named_workspace() {
  local name="$1"
  if [ -n "$name" ]; then
    nwe_herdr workspace create --label "$name" --focus >/dev/null
  else
    nwe_herdr workspace create --focus >/dev/null
  fi
}

nwe_open_worktree_workspace() {
  local repo="$1" branch base label
  {
    IFS= read -r branch
    IFS= read -r base
    IFS= read -r label
  } <<EOT
$2
EOT
  if nwe_has_worktree "$repo" "$branch"; then
    nwe_herdr worktree open --cwd "$repo" --branch "$branch" --focus >/dev/null
  elif [ -n "$base" ]; then
    nwe_herdr worktree create --cwd "$repo" --branch "$branch" --base "$base" --label "$label" --focus >/dev/null
  else
    nwe_herdr worktree create --cwd "$repo" --branch "$branch" --label "$label" --focus >/dev/null
  fi
}
