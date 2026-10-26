setup() {
  load helper
  source "$REPO_ROOT/lib/issue.sh"
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

@test "nwe_issue_branch joins the number and the slug" {
  run nwe_issue_branch 12 "Add login page"

  [ "$output" = 12-add-login-page ]
}

@test "nwe_issue_branch falls back to issue-<number> when the slug is empty" {
  run nwe_issue_branch 15 "ログイン画面を直す"

  [ "$output" = issue-15 ]
}

@test "nwe_issue_lines lists the number as the key and shows the title with labels" {
  run nwe_issue_lines <"$BATS_TEST_DIRNAME/fixtures/issues.json"

  [ "${lines[0]}" = "$(printf '12\t#12 Add login page  [enhancement, ui]')" ]
  [ "${lines[1]}" = "$(printf '15\t#15 ログイン画面を直す')" ]
}

@test "nwe_issue_title finds the title by number" {
  run nwe_issue_title 15 <"$BATS_TEST_DIRNAME/fixtures/issues.json"

  [ "$output" = "ログイン画面を直す" ]
}
