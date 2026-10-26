setup() {
  load helper
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
