# shellcheck shell=bash

nwe_github_issue_available() {
  nwe_has_origin "$1"
}

nwe_github_issue_items() {
  nwe_github_issue_pages || {
    nwe_notice "gh could not list the open issues."
    return 1
  }
}

nwe_github_issue_choose() {
  local toggle limit
  toggle="$(nwe_toggle_mine_key)" || return 1
  limit="$(nwe_github_issue_limit)" || return 1
  export -f nwe_github_issue_pages nwe_github_issue_format nwe_github_issue_take nwe_github_issue_all nwe_github_issue_mine nwe_github_issue_toggle
  nwe_choose "Issue> " --with-shell "$BASH -c" --header "$toggle: assigned to me / all" --bind "$toggle:transform:nwe_github_issue_toggle $limit" --preview 'gh issue view {1}' --preview-window 'down,50%,wrap' < <(nwe_github_issue_stream "$1" | nwe_github_issue_take "$limit")
}

nwe_github_issue_resolve() {
  local number="$2" title branch base
  title="$(gh issue view "$number" --json title | jq -r .title)" || {
    nwe_notice "gh could not read issue #$number."
    return 1
  }
  branch="$(nwe_input "Branch> " "$(nwe_github_issue_branch "$number" "$title")")" || return 1
  [ -n "$branch" ] || return 1
  base="$(nwe_latest_default_commit)" || {
    nwe_notice "Could not fetch the latest default branch from origin."
    return 1
  }
  printf '%s\n%s\n%s\n' "$branch" "$base" "#$number $title"
}

# shellcheck disable=SC2016
nwe_github_issue_pages() {
  gh api graphql -F owner='{owner}' -F name='{repo}' -f query='query($owner: String!, $name: String!, $endCursor: String, $filterBy: IssueFilters) { repository(owner: $owner, name: $name) { issues(first: 100, after: $endCursor, states: OPEN, filterBy: $filterBy, orderBy: {field: CREATED_AT, direction: DESC}) { nodes { number title labels(first: 20) { nodes { name } } } pageInfo { hasNextPage endCursor } } } }' "$@"
}

nwe_github_issue_stream() {
  local page="$1" cursor
  printf '%s\n' "$page" | nwe_github_issue_lines
  cursor="$(printf '%s\n' "$page" | jq -r '.data.repository.issues.pageInfo | select(.hasNextPage) | .endCursor')"
  if [ -n "$cursor" ]; then
    nwe_github_issue_pages --paginate -f endCursor="$cursor" --jq "$(nwe_github_issue_format)" 2>/dev/null
  fi
}

nwe_github_issue_all() {
  nwe_github_issue_pages --paginate --jq "$(nwe_github_issue_format)" 2>/dev/null | nwe_github_issue_take "${1:-}"
}

nwe_github_issue_mine() {
  local login
  login="$(gh api user --cache 24h --jq .login 2>/dev/null)" || return 1
  nwe_github_issue_pages --paginate -f "filterBy[assignee]=$login" --jq "$(nwe_github_issue_format)" 2>/dev/null | nwe_github_issue_take "${1:-}"
}

nwe_github_issue_toggle() {
  if [ "$FZF_PROMPT" = "Issue> " ]; then
    printf 'change-prompt(My issue> )+reload(nwe_github_issue_mine %s)\n' "${1:-}"
  else
    printf 'change-prompt(Issue> )+reload(nwe_github_issue_all %s)\n' "${1:-}"
  fi
}

nwe_github_issue_limit() {
  local limit
  limit="$(nwe_config .limits.issues "")" || return 1
  if [ -n "$limit" ] && ! [[ "$limit" =~ ^[1-9][0-9]*$ ]]; then
    nwe_notice "limits.issues in config.json must be a positive whole number, not $limit."
    return 1
  fi
  printf '%s\n' "$limit"
}

nwe_github_issue_take() {
  if [ -n "$1" ]; then
    head -n "$1"
  else
    cat
  fi
}

nwe_github_issue_lines() {
  jq -r "$(nwe_github_issue_format)"
}

nwe_github_issue_format() {
  printf '%s\n' '.data.repository.issues.nodes[] | "\(.number)\t#\(.number) \(.title | gsub("\t"; " "))\(if (.labels.nodes | length) > 0 then "  [\(.labels.nodes | map(.name) | join(", "))]" else "" end)"'
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
