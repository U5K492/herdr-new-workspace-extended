setup() {
  load helper
  setup_stubs
  source "$REPO_ROOT/sources/github-pr.sh"
}

@test "nwe_github_pr_lines lists the number as the key and shows the title, head and author" {
  run nwe_github_pr_lines <"$BATS_TEST_DIRNAME/fixtures/prs.json"

  [ "${lines[0]}" = "$(printf '34\t#34 Add feature X  (feature-x by @alice)')" ]
}

@test "nwe_github_pr_lines marks PRs from forks" {
  run nwe_github_pr_lines <"$BATS_TEST_DIRNAME/fixtures/prs.json"

  [ "${lines[1]}" = "$(printf '35\t#35 Fix typo  (patch-1 by @bob, fork)')" ]
}

@test "nwe_github_pr_all lists the open pull requests" {
  run nwe_github_pr_all

  [ "${#lines[@]}" -eq 2 ]
  [[ "$(gh_calls)" != *"[--author]"* ]]
}

@test "nwe_github_pr_mine lists the open pull requests opened by the signed-in user" {
  export GH_STUB_LOGIN=alice

  run nwe_github_pr_mine

  [ "$output" = "$(printf '34\t#34 Add feature X  (feature-x by @alice)')" ]
  [[ "$(gh_calls)" == *"[--author][@me]"* ]]
}

@test "nwe_github_pr_review lists the open pull requests that request my review" {
  run nwe_github_pr_review

  [ "${#lines[@]}" -eq 2 ]
  [[ "$(gh_calls)" == *"[--search][review-requested:@me]"* ]]
}

@test "nwe_github_pr_toggle mine switches all the open pull requests to the ones opened by me" {
  FZF_PROMPT="Pull request> " run nwe_github_pr_toggle mine

  [ "$output" = "change-prompt(My pull request> )+reload(nwe_github_pr_mine)" ]
}

@test "nwe_github_pr_toggle mine switches the pull requests opened by me back to all the open pull requests" {
  FZF_PROMPT="My pull request> " run nwe_github_pr_toggle mine

  [ "$output" = "change-prompt(Pull request> )+reload(nwe_github_pr_all)" ]
}

@test "nwe_github_pr_toggle review switches all the open pull requests to the ones that request my review" {
  FZF_PROMPT="Pull request> " run nwe_github_pr_toggle review

  [ "$output" = "change-prompt(Review request> )+reload(nwe_github_pr_review)" ]
}

@test "nwe_github_pr_toggle review switches the pull requests opened by me to the ones that request my review" {
  FZF_PROMPT="My pull request> " run nwe_github_pr_toggle review

  [ "$output" = "change-prompt(Review request> )+reload(nwe_github_pr_review)" ]
}

@test "nwe_github_pr_toggle review switches the pull requests that request my review back to all the open pull requests" {
  FZF_PROMPT="Review request> " run nwe_github_pr_toggle review

  [ "$output" = "change-prompt(Pull request> )+reload(nwe_github_pr_all)" ]
}
