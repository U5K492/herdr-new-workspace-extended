#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/ui.sh
source "$root/lib/ui.sh"
# shellcheck source=../lib/create.sh
source "$root/lib/create.sh"
# shellcheck source=../lib/repo.sh
source "$root/lib/repo.sh"
# shellcheck source=../lib/issue.sh
source "$root/lib/issue.sh"

choice="$(nwe_menu "$(printf 'name\tNew workspace with a name\nissue\tFrom a GitHub issue')")" || exit 0

case "$choice" in
name)
  name="$(nwe_input "Workspace name> " "")" || exit 0
  nwe_create_named_workspace "$name"
  ;;
issue)
  repo="$(nwe_repo_root "$(nwe_context_cwd)")"
  cd "$repo"
  issues="$(nwe_issue_list)"
  number="$(nwe_choose "Issue> " "$(printf '%s\n' "$issues" | nwe_issue_lines)" --preview 'gh issue view {1}' --preview-window 'down,50%,wrap')" || exit 0
  title="$(printf '%s\n' "$issues" | nwe_issue_title "$number")"
  branch="$(nwe_input "Branch> " "$(nwe_issue_branch "$number" "$title")")" || exit 0
  [ -n "$branch" ] || exit 0
  base="$(nwe_latest_default_commit)"
  nwe_create_worktree_workspace "$repo" "$branch" "$base" "#$number $title"
  ;;
esac
