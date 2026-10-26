#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/ui.sh
source "$root/lib/ui.sh"
# shellcheck source=../lib/create.sh
source "$root/lib/create.sh"
# shellcheck source=../lib/repo.sh
source "$root/lib/repo.sh"
# shellcheck source=../sources/github-issue.sh
source "$root/sources/github-issue.sh"
# shellcheck source=../sources/github-pr.sh
source "$root/sources/github-pr.sh"

choice="$(nwe_menu "$(printf 'name\tNew workspace with a name\ngithub_issue\tFrom a GitHub issue\ngithub_pr\tFrom a GitHub pull request')")" || exit 0

if [ "$choice" = name ]; then
  name="$(nwe_input "Workspace name> " "")" || exit 0
  nwe_create_named_workspace "$name"
  exit 0
fi

repo="$(nwe_repo_root "$(nwe_context_cwd)")"
cd "$repo"
items="$("nwe_${choice}_items")"
key="$("nwe_${choice}_choose" "$items")" || exit 0
target="$("nwe_${choice}_resolve" "$items" "$key")" || exit 0
nwe_open_worktree_workspace "$repo" "$target"
