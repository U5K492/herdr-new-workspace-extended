# shellcheck shell=bash

nwe_github_issue_available() {
  nwe_has_origin "$1"
}

nwe_github_issue_items() {
  gh issue list --state open --limit 100 --json number,title,labels || {
    nwe_notice "gh could not list the open issues."
    return 1
  }
}

nwe_github_issue_choose() {
  nwe_choose "Issue> " "$(printf '%s\n' "$1" | nwe_github_issue_lines)" --preview 'gh issue view {1}' --preview-window 'down,50%,wrap'
}

nwe_github_issue_resolve() {
  local number="$2" title branch base
  title="$(printf '%s\n' "$1" | jq -r --argjson number "$number" '.[] | select(.number == $number) | .title')" || return 1
  branch="$(nwe_input "Branch> " "$(nwe_github_issue_branch "$number" "$title")")" || return 1
  [ -n "$branch" ] || return 1
  base="$(nwe_latest_default_commit)" || {
    nwe_notice "Could not fetch the latest default branch from origin."
    return 1
  }
  printf '%s\n%s\n%s\n' "$branch" "$base" "#$number $title"
}

nwe_github_issue_lines() {
  jq -r '.[] | "\(.number)\t#\(.number) \(.title | gsub("\t"; " "))\(if (.labels | length) > 0 then "  [\(.labels | map(.name) | join(", "))]" else "" end)"'
}

nwe_github_issue_branch() {
  local number="$1" slug
  slug="$(nwe_slug "$2")"
  if [ -n "$slug" ]; then
    printf '%s-%s\n' "$number" "$slug"
  else
    printf 'issue-%s\n' "$number"
  fi
}

nwe_slug() {
  printf '%s' "$1" |
    LC_ALL=C tr '[:upper:]' '[:lower:]' |
    LC_ALL=C tr -cs 'a-z0-9' '-' |
    sed -e 's/^-//' -e 's/-$//' |
    cut -c1-40 |
    sed 's/-$//'
}
