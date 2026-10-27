# shellcheck shell=bash

nwe_herdr() {
  "${HERDR_BIN_PATH:-herdr}" "$@"
}

nwe_context_cwd() {
  printf '%s' "${NWE_CONTEXT_JSON:-}" | jq -r '.focused_pane_cwd // .workspace_cwd // empty'
}

nwe_create_named_workspace() {
  local name="$1" created
  if [ -n "$name" ]; then
    created="$(nwe_herdr workspace create --label "$name" --focus)" || return 1
  else
    created="$(nwe_herdr workspace create --focus)" || return 1
  fi
  nwe_start_agent "$created" "$name"
}

nwe_open_worktree_workspace() {
  local repo="$1" branch base label opened
  {
    IFS= read -r branch
    IFS= read -r base
    IFS= read -r label
  } <<EOT
$2
EOT
  if nwe_has_worktree "$repo" "$branch"; then
    opened="$(nwe_herdr worktree open --cwd "$repo" --branch "$branch" --focus)" || return 1
  else
    nwe_progress "Creating a worktree for $branch..."
    if [ -n "$base" ]; then
      opened="$(nwe_herdr worktree create --cwd "$repo" --branch "$branch" --base "$base" --label "$label" --focus)" || return 1
    else
      opened="$(nwe_herdr worktree create --cwd "$repo" --branch "$branch" --label "$label" --focus)" || return 1
    fi
  fi
  nwe_start_agent "$opened" "$branch"
}

nwe_start_agent() {
  local opened="$1" name="$2" kind workspace pane
  kind="$(nwe_config .agent.kind "")" || return 1
  [ -n "$kind" ] || return 0
  [ "$(printf '%s' "$opened" | jq -r '.result.already_open // false')" = false ] || return 0
  workspace="$(printf '%s' "$opened" | jq -r '.result.workspace.workspace_id')" || return 1
  pane="$(printf '%s' "$opened" | jq -r '.result.root_pane.pane_id')" || return 1
  name="$(nwe_agent_name "$kind" "$name" "$workspace")" || return 1
  trap '' HUP
  nwe_run_agent "$kind" "$name" "$pane" </dev/null >/dev/null 2>&1 &
  trap - HUP
}

nwe_agent_name() {
  local kind="$1" name workspace="$3"
  name="$(nwe_agent_slug "$2")"
  case "$name" in
    [a-z]*) ;;
    *) name="$(nwe_agent_slug "$kind-$name")" ;;
  esac
  if nwe_herdr agent get "$name" >/dev/null 2>&1; then
    name="$(nwe_agent_slug "$(printf '%s' "$name" | cut -c1-24)-$workspace")"
  fi
  printf '%s\n' "$name"
}

nwe_agent_slug() {
  printf '%s' "$1" |
    LC_ALL=C tr '[:upper:]' '[:lower:]' |
    LC_ALL=C sed -e 's/[^a-z0-9_-][^a-z0-9_-]*/-/g' -e 's/--*/-/g' -e 's/^-//' |
    cut -c1-32 |
    sed 's/-$//'
}

nwe_run_agent() {
  local kind="$1" name="$2" pane="$3" error title
  error="$(nwe_herdr agent start "$name" --kind "$kind" --pane "$pane" 2>&1 >/dev/null)" && return 0
  title="Could not start $kind"
  if [ "$(printf '%s' "$error" | jq -Rrs 'fromjson? | .error.code')" = agent_not_ready ]; then
    title="$kind is waiting for an answer"
  fi
  nwe_herdr notification show "$title" --body "$(printf '%s' "$error" | jq -Rrs '(fromjson? | .error.message) // .')"
}
