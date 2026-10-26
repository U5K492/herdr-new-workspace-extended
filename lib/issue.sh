# shellcheck shell=bash

nwe_issue_list() {
  gh issue list --state open --limit 100 --json number,title,labels
}

nwe_issue_lines() {
  jq -r '.[] | "\(.number)\t#\(.number) \(.title | gsub("\t"; " "))\(if (.labels | length) > 0 then "  [\(.labels | map(.name) | join(", "))]" else "" end)"'
}

nwe_issue_title() {
  jq -r --argjson number "$1" '.[] | select(.number == $number) | .title'
}

nwe_slug() {
  printf '%s' "$1" |
    LC_ALL=C tr '[:upper:]' '[:lower:]' |
    LC_ALL=C tr -cs 'a-z0-9' '-' |
    sed -e 's/^-//' -e 's/-$//' |
    cut -c1-40 |
    sed 's/-$//'
}

nwe_issue_branch() {
  local number="$1" slug
  slug="$(nwe_slug "$2")"
  if [ -n "$slug" ]; then
    printf '%s-%s\n' "$number" "$slug"
  else
    printf 'issue-%s\n' "$number"
  fi
}
