# shellcheck shell=bash

nwe_context_cwd() {
  printf '%s' "${NWE_CONTEXT_JSON:-}" | jq -r '.focused_pane_cwd // .workspace_cwd // empty'
}

nwe_repo_root() {
  local cwd="$1" common
  [ -n "$cwd" ] || return 1
  common="$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || return 1
  dirname "$common"
}

nwe_latest_default_commit() {
  local branch
  branch="$(gh repo view --json defaultBranchRef | jq -r '.defaultBranchRef.name')"
  git fetch --quiet origin "$branch"
  git rev-parse --verify --quiet "refs/remotes/origin/$branch^{commit}"
}
