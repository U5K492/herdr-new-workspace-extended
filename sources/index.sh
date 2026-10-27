# shellcheck shell=bash

# shellcheck source=github.sh
source "$(dirname "${BASH_SOURCE[0]}")/github.sh"
# shellcheck source=github-issue.sh
source "$(dirname "${BASH_SOURCE[0]}")/github-issue.sh"
# shellcheck source=github-pr.sh
source "$(dirname "${BASH_SOURCE[0]}")/github-pr.sh"

nwe_sources() {
  printf 'github_issue\tFrom a GitHub issue\n'
  printf 'github_pr\tFrom a GitHub pull request\n'
}

nwe_available_sources() {
  local repo="$1" source title
  [ -n "$repo" ] || return 0
  while IFS=$'\t' read -r source title; do
    if "nwe_${source}_available" "$repo"; then
      printf '%s\t%s\n' "$source" "$title"
    fi
  done <<EOF_SOURCES
$(nwe_sources)
EOF_SOURCES
}
