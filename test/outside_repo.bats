setup() {
  load helper
  setup_stubs
  setup_git_repo
  export GIT_CEILING_DIRECTORIES="$BATS_TEST_TMPDIR"
}

@test "outside git, the picker skips the menu and asks for a name" {
  mkdir -p "$BATS_TEST_TMPDIR/plain"
  fzf_will_type foo

  run_picker_from "$BATS_TEST_TMPDIR/plain"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = '[workspace][create][--label][foo][--focus]' ]
  [ "$(wc -l <"$FZF_STUB_DIR/calls")" -eq 1 ]
}

@test "in a repo without origin, the menu offers only a name and a branch name" {
  git -C "$REPO" remote remove origin
  fzf_will_cancel

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(fzf_input 1 | cut -f1 | tr '\n' ' ')" = "name branch " ]
}

@test "without a context, the picker skips the menu and asks for a name" {
  fzf_will_type foo

  run_picker

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = '[workspace][create][--label][foo][--focus]' ]
}

@test "when gh fails to list issues, the picker shows the error, waits for a key and creates nothing" {
  export GH_STUB_FAIL="api graphql"
  fzf_will_select github_issue

  run_picker_from "$REPO"

  [ "$status" -ne 0 ]
  [[ "$output" == *"HTTP 401: Bad credentials"* ]]
  [[ "$output" == *"Press any key to close."* ]]
  [ -z "$(herdr_calls)" ]
}

@test "when gh fails to read the chosen issue, the picker shows the error, waits for a key and creates nothing" {
  export GH_STUB_FAIL="issue view"
  fzf_will_select github_issue
  fzf_will_select 12

  run_picker_from "$REPO"

  [[ "$output" == *"HTTP 401: Bad credentials"* ]]
  [[ "$output" == *"gh could not read issue #12."* ]]
  [ -z "$(herdr_calls)" ]
}

@test "when gh fails to list PRs, the picker shows the error, waits for a key and creates nothing" {
  export GH_STUB_FAIL="pr list"
  fzf_will_select github_pr

  run_picker_from "$REPO"

  [ "$status" -ne 0 ]
  [[ "$output" == *"HTTP 401: Bad credentials"* ]]
  [[ "$output" == *"Press any key to close."* ]]
  [ -z "$(herdr_calls)" ]
}

@test "when gh fails to read the chosen PR, the picker shows the error, waits for a key and creates nothing" {
  export GH_STUB_FAIL="pr view"
  fzf_will_select github_pr
  fzf_will_select 34

  run_picker_from "$REPO"

  [[ "$output" == *"HTTP 401: Bad credentials"* ]]
  [[ "$output" == *"gh could not read PR #34."* ]]
  [ -z "$(herdr_calls)" ]
}

@test "when gh fails to find the default branch, the picker shows the error, waits for a key and creates nothing" {
  export GH_STUB_FAIL="repo view"
  fzf_will_select github_issue
  fzf_will_select 12
  fzf_will_accept

  run_picker_from "$REPO"

  [[ "$output" == *"HTTP 401: Bad credentials"* ]]
  [[ "$output" == *"Press any key to close."* ]]
  [ -z "$(herdr_calls)" ]
}
