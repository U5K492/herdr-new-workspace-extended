setup() {
  load helper
  setup_stubs
  setup_git_repo
}

@test "accepting the default branch for an issue creates a worktree workspace from the latest default branch" {
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[worktree][create][--cwd][$REPO][--branch][12-add-login-page][--base][$ORIGIN_MAIN_SHA][--label][#12 Add login page][--focus]" ]
}

@test "a typed branch name replaces the default" {
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_type login-page

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == *"[--branch][login-page][--base]"* ]]
}

@test "opening from a linked worktree passes the parent repo as --cwd" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/child" -b child
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$BATS_TEST_TMPDIR/child"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == "[worktree][create][--cwd][$REPO][--branch]"* ]]
}

@test "a Japanese-only title defaults the branch to issue-<number>" {
  fzf_will_select github_issue
  fzf_will_select 15
  fzf_will_accept

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == *"[--branch][issue-15][--base]"* ]]
  [[ "$(herdr_calls)" == *"[--label][#15 ログイン画面を直す]"* ]]
}

@test "the issue list previews the issue" {
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [[ "$(fzf_calls)" == *"--preview gh issue view {1}"* ]]
}

@test "ctrl-o in the issue list toggles the issues assigned to me" {
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [[ "$(fzf_calls)" == *"--header ctrl-o: assigned to me / all --bind ctrl-o:transform:nwe_github_issue_toggle"* ]]
}

@test "keys.toggle_mine in config.json replaces ctrl-o" {
  write_config '{"keys": {"toggle_mine": "alt-m"}}'
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [[ "$(fzf_calls)" == *"--header alt-m: assigned to me / all --bind alt-m:transform:nwe_github_issue_toggle"* ]]
}

@test "an issue on a later page can be picked" {
  fzf_will_select github_issue
  fzf_will_select 7
  fzf_will_accept

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == *"[--branch][7-old-issue][--base]"* ]]
  [[ "$(herdr_calls)" == *"[--label][#7 Old issue]"* ]]
}

@test "limits.issues in config.json caps the issue list and its reloads" {
  write_config '{"limits": {"issues": 2}}'
  fzf_will_select github_issue
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$(fzf_input 2 | wc -l | tr -d ' ')" -eq 2 ]
  [[ "$(fzf_input 2)" != *"#7 Old issue"* ]]
  [[ "$(fzf_calls)" == *"--bind ctrl-o:transform:nwe_github_issue_toggle 2 "* ]]
}

@test "a limits.issues that is not a positive whole number shows the error and creates nothing" {
  write_config '{"limits": {"issues": "many"}}'
  fzf_will_select github_issue

  run_picker_from "$REPO"

  [[ "$output" == *"limits.issues in config.json must be a positive whole number, not many."* ]]
  [ -z "$(herdr_calls)" ]
}

@test "an issue missing from the first list takes its title from gh" {
  source "$REPO_ROOT/lib/ui.sh"
  source "$REPO_ROOT/lib/repo.sh"
  source "$REPO_ROOT/sources/github-issue.sh"
  fzf_will_accept
  cd "$REPO"

  run nwe_github_issue_resolve "[]" 12

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 12-add-login-page ]
  [ "${lines[2]}" = "#12 Add login page" ]
}

@test "escaping the issue list creates nothing" {
  fzf_will_select github_issue
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "escaping the branch input creates nothing" {
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "confirming an empty branch name creates nothing" {
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_type ""

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "a failed fetch of the default branch creates nothing" {
  git -C "$REPO" remote set-url origin "$BATS_TEST_TMPDIR/missing.git"
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [ -z "$(herdr_calls)" ]
}
