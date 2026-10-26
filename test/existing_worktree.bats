setup() {
  load helper
  setup_stubs
  setup_git_repo
  push_origin_branch feature-x
}

@test "choosing an issue whose branch already has a worktree opens it instead of creating one" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/wt-12" -b 12-add-login-page
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[worktree][open][--cwd][$REPO][--branch][12-add-login-page][--focus]" ]
}

@test "choosing a PR whose branch already has a worktree opens it instead of creating one" {
  git -C "$REPO" fetch -q origin feature-x
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/wt-x" -b feature-x origin/feature-x
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[worktree][open][--cwd][$REPO][--branch][feature-x][--focus]" ]
}

@test "a worktree of a branch that only starts with the same name does not count" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/wt-12-old" -b 12-add-login-page-old
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == "[worktree][create][--cwd][$REPO][--branch][12-add-login-page][--base]"* ]]
}
