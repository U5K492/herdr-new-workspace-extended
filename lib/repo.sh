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

nwe_fetch_origin_commit() {
  local branch="$1"
  git fetch --quiet origin "$branch" || return 1
  git rev-parse --verify --quiet "refs/remotes/origin/$branch^{commit}"
}

nwe_track_origin_branch() {
  local branch="$1"
  git fetch --quiet origin "$branch" || return 1
  if ! git show-ref --verify --quiet "refs/heads/$branch"; then
    git branch --quiet --track "$branch" "refs/remotes/origin/$branch" || return 1
  fi
}

nwe_has_worktree() {
  local repo="$1" branch="$2" list
  list="$(git -C "$repo" worktree list --porcelain)" || return 1
  grep -Fqx "branch refs/heads/$branch" <<<"$list"
}

nwe_has_origin() {
  git -C "$1" remote get-url origin >/dev/null 2>&1
}
