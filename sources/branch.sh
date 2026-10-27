# shellcheck shell=bash

nwe_branch_available() {
  return 0
}

nwe_branch_items() {
  :
}

nwe_branch_choose() {
  local branch
  branch="$(nwe_input "Branch> " "")" || return 1
  [ -n "$branch" ] || return 1
  printf '%s\n' "$branch"
}

nwe_branch_resolve() {
  local branch="$2" base=""
  git check-ref-format --branch "$branch" >/dev/null 2>&1 || {
    nwe_notice "$branch is not a valid branch name."
    return 1
  }
  if nwe_has_origin "$PWD"; then
    base="$(nwe_branch_base)" || {
      nwe_notice "Could not fetch the latest default branch from origin."
      return 1
    }
  fi
  printf '%s\n%s\n%s\n' "$branch" "$base" "$branch"
}

nwe_branch_base() {
  local branch
  branch="$(nwe_origin_default_branch)" || return 1
  nwe_fetch_origin_commit "$branch"
}
