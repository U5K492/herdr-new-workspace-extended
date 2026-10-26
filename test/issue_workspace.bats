setup() {
  load helper
  setup_stubs
  setup_git_repo
}

@test "accepting the default branch for an issue creates a worktree workspace from the latest default branch" {
  fzf_will_select issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[worktree][create][--cwd][$REPO][--branch][12-add-login-page][--base][$ORIGIN_MAIN_SHA][--label][#12 Add login page][--focus]" ]
}

@test "a typed branch name replaces the default" {
  fzf_will_select issue
  fzf_will_select 12
  fzf_will_type login-page

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == *"[--branch][login-page][--base]"* ]]
}

@test "opening from a linked worktree passes the parent repo as --cwd" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/child" -b child
  fzf_will_select issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$BATS_TEST_TMPDIR/child"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == "[worktree][create][--cwd][$REPO][--branch]"* ]]
}

@test "a Japanese-only title defaults the branch to issue-<number>" {
  fzf_will_select issue
  fzf_will_select 15
  fzf_will_accept

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == *"[--branch][issue-15][--base]"* ]]
  [[ "$(herdr_calls)" == *"[--label][#15 ログイン画面を直す]"* ]]
}

@test "the issue list previews the issue" {
  fzf_will_select issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [[ "$(fzf_calls)" == *"--preview gh issue view {1}"* ]]
}

@test "escaping the issue list creates nothing" {
  fzf_will_select issue
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "escaping the branch input creates nothing" {
  fzf_will_select issue
  fzf_will_select 12
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "confirming an empty branch name creates nothing" {
  fzf_will_select issue
  fzf_will_select 12
  fzf_will_type ""

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}
