# shellcheck shell=bash

nwe_repo_root() {
  local cwd="$1" common
  [ -n "$cwd" ] || return 1
  common="$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || return 1
  dirname "$common"
}

nwe_origin_default_branch() {
  local head branch
  if head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD)"; then
    printf '%s\n' "${head#origin/}"
    return 0
  fi
  head="$(git ls-remote --symref origin HEAD)" || return 1
  branch="$(awk '$1 == "ref:" { sub("^refs/heads/", "", $2); print $2 }' <<<"$head")"
  [ -n "$branch" ] || return 1
  printf '%s\n' "$branch"
}

nwe_fetch_origin_commit() {
  local branch="$1"
  nwe_progress "Fetching origin/$branch..."
  git fetch --quiet origin "$branch" || return 1
  git rev-parse --verify --quiet "refs/remotes/origin/$branch^{commit}"
}

nwe_track_origin_branch() {
  local branch="$1"
  nwe_progress "Fetching origin/$branch..."
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
