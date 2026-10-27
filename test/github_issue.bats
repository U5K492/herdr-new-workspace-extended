setup() {
  load helper
  setup_stubs
  source "$REPO_ROOT/lib/ui.sh"
  source "$REPO_ROOT/lib/config.sh"
  source "$REPO_ROOT/sources/github-issue.sh"
}

@test "nwe_slug lowercases the title and replaces symbols with hyphens" {
  run nwe_slug "Fix: OAuth2 login (Safari)"

  [ "$output" = fix-oauth2-login-safari ]
}

@test "nwe_slug collapses consecutive separators" {
  run nwe_slug "a -- b__c"

  [ "$output" = a-b-c ]
}

@test "nwe_slug cuts at 40 characters without leaving a trailing hyphen" {
  run nwe_slug "Implement the new authentication worker pool"

  [ "$output" = implement-the-new-authentication-worker ]
}

@test "nwe_slug is empty for a title without ASCII letters or digits" {
  run nwe_slug "ログイン画面を直す"

  [ "$output" = "" ]
}

@test "nwe_github_issue_branch joins the number and the slug" {
  run nwe_github_issue_branch 12 "Add login page"

  [ "$output" = 12-add-login-page ]
}

@test "nwe_github_issue_branch falls back to issue-<number> when the slug is empty" {
  run nwe_github_issue_branch 15 "ログイン画面を直す"

  [ "$output" = issue-15 ]
}

@test "nwe_github_issue_base fetches the default branch gh reports and prints its commit" {
  setup_git_repo
  push_origin_branch trunk
  source "$REPO_ROOT/lib/repo.sh"
  export GH_STUB_DEFAULT_BRANCH=trunk
  cd "$REPO"

  run nwe_github_issue_base

  [ "$status" -eq 0 ]
  [ "$output" = "$(git -C "$UPSTREAM" rev-parse trunk)" ]
}

@test "nwe_github_issue_lines lists the number as the key and shows the title with labels" {
  run nwe_github_issue_lines <"$BATS_TEST_DIRNAME/fixtures/issues-page-1.json"

  [ "${lines[0]}" = "$(printf '12\t#12 Add login page  [enhancement, ui]')" ]
  [ "${lines[1]}" = "$(printf '15\t#15 ログイン画面を直す')" ]
}

@test "nwe_github_issue_lines reads one page after another" {
  run nwe_github_issue_lines < <(cat "$BATS_TEST_DIRNAME"/fixtures/issues-page-1.json "$BATS_TEST_DIRNAME"/fixtures/issues-page-2.json)

  [ "${#lines[@]}" -eq 3 ]
  [ "${lines[2]}" = "$(printf '7\t#7 Old issue')" ]
}

@test "nwe_github_issue_stream lists the first page, then fetches the rest from its end cursor" {
  run nwe_github_issue_stream "$(cat "$BATS_TEST_DIRNAME/fixtures/issues-page-1.json")"

  [ "${lines[0]}" = "$(printf '12\t#12 Add login page  [enhancement, ui]')" ]
  [ "${lines[2]}" = "$(printf '7\t#7 Old issue')" ]
  [[ "$(gh_calls)" == "[api][graphql]"*"[--paginate][-f][endCursor=cursor-1][--jq]"* ]]
}

@test "nwe_github_issue_stream fetches nothing more when the first page is the last" {
  run nwe_github_issue_stream "$(cat "$BATS_TEST_DIRNAME/fixtures/issues-page-2.json")"

  [ "$output" = "$(printf '7\t#7 Old issue')" ]
  [ -z "$(gh_calls)" ]
}

@test "nwe_github_issue_all lists the open issues on every page" {
  run nwe_github_issue_all

  [ "${#lines[@]}" -eq 3 ]
  [[ "$(gh_calls)" == "[api][graphql]"*"[--paginate][--jq]"* ]]
}

@test "nwe_github_issue_all stops at the limit" {
  run nwe_github_issue_all 2

  [ "${#lines[@]}" -eq 2 ]
}

@test "nwe_github_issue_mine lists the open issues assigned to the signed-in user" {
  export GH_STUB_LOGIN=alice

  run nwe_github_issue_mine

  [ "${#lines[@]}" -eq 3 ]
  [[ "$(gh_calls)" == *"[--paginate][-f][filterBy[assignee]=alice][--jq]"* ]]
}

@test "nwe_github_issue_toggle switches all the open issues to the ones assigned to me" {
  FZF_PROMPT="Issue> " run nwe_github_issue_toggle 50

  [ "$output" = "change-prompt(My issue> )+reload(nwe_github_issue_mine 50)" ]
}

@test "nwe_github_issue_toggle switches the issues assigned to me back to all the open issues" {
  FZF_PROMPT="My issue> " run nwe_github_issue_toggle

  [ "$output" = "change-prompt(Issue> )+reload(nwe_github_issue_all )" ]
}

@test "nwe_github_issue_limit is empty without limits.issues" {
  run nwe_github_issue_limit

  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "nwe_github_issue_limit reads limits.issues from config.json" {
  write_config '{"limits": {"issues": 300}}'

  run nwe_github_issue_limit

  [ "$output" = 300 ]
}

@test "nwe_github_issue_limit shows an error for a limit that is not a positive whole number" {
  write_config '{"limits": {"issues": 0}}'

  run nwe_github_issue_limit </dev/null

  [ "$status" -ne 0 ]
  [[ "$output" == *"limits.issues in config.json must be a positive whole number, not 0."* ]]
}
