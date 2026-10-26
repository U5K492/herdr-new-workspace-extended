# shellcheck shell=bash

nwe_github_pr_items() {
  gh pr list --state open --limit 100 --json number,title,headRefName,isCrossRepository,author
}

nwe_github_pr_choose() {
  nwe_choose "Pull request> " "$(printf '%s\n' "$1" | nwe_github_pr_lines)" --preview 'gh pr view {1}' --preview-window 'down,50%,wrap'
}

nwe_github_pr_resolve() {
  local number="$2" pr head title
  pr="$(printf '%s\n' "$1" | jq -c --argjson number "$number" '.[] | select(.number == $number)')" || return 1
  if [ "$(printf '%s\n' "$pr" | jq -r .isCrossRepository)" = true ]; then
    nwe_notice "PR #$number comes from a fork. Pull requests from forks are not supported yet."
    return 1
  fi
  head="$(printf '%s\n' "$pr" | jq -r .headRefName)" || return 1
  title="$(printf '%s\n' "$pr" | jq -r .title)" || return 1
  nwe_track_origin_branch "$head" || return 1
  printf '%s\n%s\n%s\n' "$head" "" "PR #$number $title"
}

nwe_github_pr_lines() {
  jq -r '.[] | "\(.number)\t#\(.number) \(.title | gsub("\t"; " "))  (\(.headRefName) by @\(.author.login)\(if .isCrossRepository then ", fork" else "" end))"'
}
