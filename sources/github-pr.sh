# shellcheck shell=bash

nwe_github_pr_available() {
  nwe_has_origin "$1"
}

nwe_github_pr_items() {
  nwe_github_pr_list || {
    nwe_notice "gh could not list the open pull requests."
    return 1
  }
}

nwe_github_pr_choose() {
  local toggle
  toggle="$(nwe_toggle_mine_key)" || return 1
  export -f nwe_github_pr_list nwe_github_pr_lines nwe_github_pr_all nwe_github_pr_mine nwe_github_pr_toggle
  printf '%s\n' "$1" | nwe_github_pr_lines | nwe_choose "Pull request> " --with-shell "$BASH -c" --header "$toggle: opened by me / all" --bind "$toggle:transform:nwe_github_pr_toggle" --preview 'gh pr view {1}' --preview-window 'down,50%,wrap'
}

nwe_github_pr_resolve() {
  local number="$2" pr head title
  pr="$(gh pr view "$number" --json headRefName,isCrossRepository,title)" || {
    nwe_notice "gh could not read PR #$number."
    return 1
  }
  if [ "$(printf '%s\n' "$pr" | jq -r .isCrossRepository)" = true ]; then
    nwe_notice "PR #$number comes from a fork. Pull requests from forks are not supported yet."
    return 1
  fi
  head="$(printf '%s\n' "$pr" | jq -r .headRefName)" || return 1
  title="$(printf '%s\n' "$pr" | jq -r .title)" || return 1
  nwe_track_origin_branch "$head" || {
    nwe_notice "Could not fetch $head from origin."
    return 1
  }
  printf '%s\n%s\n%s\n' "$head" "" "PR #$number $title"
}

nwe_github_pr_list() {
  gh pr list --state open --limit 100 --json number,title,headRefName,isCrossRepository,author "$@"
}

nwe_github_pr_all() {
  nwe_github_pr_list 2>/dev/null | nwe_github_pr_lines
}

nwe_github_pr_mine() {
  nwe_github_pr_list --author @me 2>/dev/null | nwe_github_pr_lines
}

nwe_github_pr_toggle() {
  if [ "$FZF_PROMPT" = "Pull request> " ]; then
    printf 'change-prompt(My pull request> )+reload(nwe_github_pr_mine)\n'
  else
    printf 'change-prompt(Pull request> )+reload(nwe_github_pr_all)\n'
  fi
}

nwe_github_pr_lines() {
  jq -r '.[] | "\(.number)\t#\(.number) \(.title | gsub("\t"; " "))  (\(.headRefName) by @\(.author.login)\(if .isCrossRepository then ", fork" else "" end))"'
}
