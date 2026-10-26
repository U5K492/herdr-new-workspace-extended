#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/ui.sh
source "$root/lib/ui.sh"
# shellcheck source=../lib/config.sh
source "$root/lib/config.sh"
# shellcheck source=../lib/create.sh
source "$root/lib/create.sh"
# shellcheck source=../lib/repo.sh
source "$root/lib/repo.sh"
# shellcheck source=../lib/sources.sh
source "$root/lib/sources.sh"
# shellcheck source=../sources/github-issue.sh
source "$root/sources/github-issue.sh"
# shellcheck source=../sources/github-pr.sh
source "$root/sources/github-pr.sh"

repo="$(nwe_repo_root "$(nwe_context_cwd)")" || repo=""
sources="$(nwe_available_sources "$repo")"
choice=name
if [ -n "$sources" ]; then
  choice="$(nwe_menu "$(printf 'name\tNew workspace with a name\n%s' "$sources")")" || exit 0
fi

if [ "$choice" = name ]; then
  name="$(nwe_input "Workspace name> " "")" || exit 0
  nwe_create_named_workspace "$name"
  exit 0
fi

cd "$repo"
items="$("nwe_${choice}_items")" || exit 1
key="$("nwe_${choice}_choose" "$items")" || exit 0
target="$("nwe_${choice}_resolve" "$items" "$key")" || exit 0
nwe_open_worktree_workspace "$repo" "$target"
