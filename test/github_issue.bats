setup() {
  load helper
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

@test "nwe_github_issue_lines lists the number as the key and shows the title with labels" {
  run nwe_github_issue_lines <"$BATS_TEST_DIRNAME/fixtures/issues.json"

  [ "${lines[0]}" = "$(printf '12\t#12 Add login page  [enhancement, ui]')" ]
  [ "${lines[1]}" = "$(printf '15\t#15 ログイン画面を直す')" ]
}

@test "nwe_github_issue_list passes extra flags to gh issue list" {
  setup_stubs

  run nwe_github_issue_list --assignee @me

  [ "$(gh_calls)" = "[issue][list][--state][open][--limit][100][--json][number,title,labels][--assignee][@me]" ]
}

@test "nwe_github_issue_toggle switches all the open issues to the ones assigned to me" {
  FZF_PROMPT="Issue> " run nwe_github_issue_toggle

  [ "$output" = "change-prompt(My issue> )+reload(nwe_github_issue_list --assignee @me | nwe_github_issue_lines)" ]
}

@test "nwe_github_issue_toggle switches the issues assigned to me back to all the open issues" {
  FZF_PROMPT="My issue> " run nwe_github_issue_toggle

  [ "$output" = "change-prompt(Issue> )+reload(nwe_github_issue_list | nwe_github_issue_lines)" ]
}
