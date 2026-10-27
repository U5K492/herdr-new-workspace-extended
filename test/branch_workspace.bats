setup() {
  load helper
  setup_stubs
  setup_git_repo
}

@test "the menu offers a branch name after a plain name" {
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$(fzf_input 1 | cut -f1 | head -n 2 | tr '\n' ' ')" = "name branch " ]
}

@test "typing a branch name creates a worktree workspace from the latest default branch" {
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[worktree][create][--cwd][$REPO][--branch][my-feature][--base][$ORIGIN_MAIN_SHA][--label][my-feature][--focus]" ]
}

@test "the popup shows what it is waiting for while it fetches and creates the worktree" {
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Fetching origin/main..."*"Creating a worktree for my-feature..."* ]]
}

@test "the base follows the default branch that origin/HEAD points to" {
  push_origin_branch develop
  git -C "$REPO" fetch -q origin develop
  git -C "$REPO" remote set-head origin develop
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$(herdr_calls)" == *"[--base][$(git -C "$UPSTREAM" rev-parse develop)]"* ]]
}

@test "the branch name does not need gh" {
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ -z "$(gh_calls)" ]
}

@test "in a repo without origin, the worktree branches from where herdr decides" {
  git -C "$REPO" remote remove origin
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[worktree][create][--cwd][$REPO][--branch][my-feature][--label][my-feature][--focus]" ]
}

@test "a branch that already has a worktree is opened instead of created" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/wt" -b my-feature
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[worktree][open][--cwd][$REPO][--branch][my-feature][--focus]" ]
  [[ "$output" != *"Creating a worktree"* ]]
}

@test "an invalid branch name shows the error and creates nothing" {
  fzf_will_select branch
  fzf_will_type "my feature"

  run_picker_from "$REPO"

  [[ "$output" == *"my feature is not a valid branch name."* ]]
  [ -z "$(herdr_calls)" ]
}

@test "confirming an empty branch name creates nothing" {
  fzf_will_select branch
  fzf_will_type ""

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "escaping the branch input creates nothing" {
  fzf_will_select branch
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "a failed fetch of the default branch shows the error and creates nothing" {
  git -C "$REPO" remote set-url origin "$BATS_TEST_TMPDIR/missing.git"
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [[ "$output" == *"Could not fetch the latest default branch from origin."* ]]
  [ -z "$(herdr_calls)" ]
}
