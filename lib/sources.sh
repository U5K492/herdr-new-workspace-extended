# shellcheck shell=bash

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
