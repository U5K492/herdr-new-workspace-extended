setup() {
  load helper
  setup_stubs
  setup_git_repo
  push_origin_branch feature-x
}

@test "choosing a PR from the same repo creates a worktree workspace on a local branch tracking its head" {
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(git -C "$REPO" rev-parse --abbrev-ref 'feature-x@{upstream}')" = origin/feature-x ]
  [ "$(git -C "$REPO" rev-parse feature-x)" = "$(git -C "$UPSTREAM" rev-parse feature-x)" ]
  [ "$(herdr_calls)" = "[worktree][create][--cwd][$REPO][--branch][feature-x][--label][PR #34 Add feature X][--focus]" ]
}

@test "an existing local branch for the PR is kept as is" {
  git -C "$REPO" branch -q feature-x main
  before="$(git -C "$REPO" rev-parse feature-x)"
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(git -C "$REPO" rev-parse feature-x)" = "$before" ]
  [[ "$(herdr_calls)" == "[worktree][create][--cwd][$REPO][--branch][feature-x][--label]"* ]]
}

@test "choosing a PR from a fork says it is not supported and creates nothing" {
  fzf_will_select github_pr
  fzf_will_select 35

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [[ "$output" == *"from forks are not supported"* ]]
  [ -z "$(herdr_calls)" ]
}

@test "the PR list previews the PR" {
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [[ "$(fzf_calls)" == *"--preview gh pr view {1}"* ]]
}

@test "ctrl-o in the PR list toggles the pull requests opened by me, and ctrl-r the ones that request my review" {
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [[ "$(fzf_calls)" == *"--header ctrl-o: opened by me / all, ctrl-r: review requested / all --bind ctrl-o:transform:nwe_github_pr_toggle mine --bind ctrl-r:transform:nwe_github_pr_toggle review "* ]]
}

@test "keys.toggle_mine in config.json replaces ctrl-o in the PR list" {
  write_config '{"keys": {"toggle_mine": "alt-m"}}'
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [[ "$(fzf_calls)" == *"--header alt-m: opened by me / all, ctrl-r: review requested / all --bind alt-m:transform:nwe_github_pr_toggle mine "* ]]
}

@test "keys.toggle_review_requested in config.json replaces ctrl-r in the PR list" {
  write_config '{"keys": {"toggle_review_requested": "alt-r"}}'
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [[ "$(fzf_calls)" == *"--header ctrl-o: opened by me / all, alt-r: review requested / all --bind ctrl-o:transform:nwe_github_pr_toggle mine --bind alt-r:transform:nwe_github_pr_toggle review "* ]]
}

@test "a PR missing from the first list takes its head and title from gh" {
  source "$REPO_ROOT/lib/ui.sh"
  source "$REPO_ROOT/lib/repo.sh"
  source "$REPO_ROOT/sources/github-pr.sh"
  cd "$REPO"

  run nwe_github_pr_resolve "[]" 34

  [ "$status" -eq 0 ]
  [ "$output" = "$(printf 'feature-x\n\nPR #34 Add feature X')" ]
}

@test "escaping the PR list creates nothing" {
  fzf_will_select github_pr
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "a failed fetch of the PR head creates nothing" {
  git -C "$REPO" remote set-url origin "$BATS_TEST_TMPDIR/missing.git"
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [ -z "$(herdr_calls)" ]
  ! git -C "$REPO" show-ref --verify --quiet refs/heads/feature-x
}
