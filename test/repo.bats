setup() {
  load helper
  setup_git_repo
  source "$REPO_ROOT/lib/repo.sh"
}

@test "nwe_context_cwd prefers the focused pane cwd" {
  export NWE_CONTEXT_JSON='{"workspace_cwd":"/w","focused_pane_cwd":"/p"}'

  run nwe_context_cwd

  [ "$output" = /p ]
}

@test "nwe_context_cwd falls back to the workspace cwd" {
  export NWE_CONTEXT_JSON='{"workspace_cwd":"/w"}'

  run nwe_context_cwd

  [ "$output" = /w ]
}

@test "nwe_context_cwd is empty without a context" {
  unset NWE_CONTEXT_JSON

  run nwe_context_cwd

  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "nwe_repo_root resolves a subdirectory to the repo root" {
  mkdir -p "$REPO/src/app"

  run nwe_repo_root "$REPO/src/app"

  [ "$status" -eq 0 ]
  [ "$output" = "$REPO" ]
}

@test "nwe_repo_root resolves a linked worktree to the parent repo" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/child" -b child

  run nwe_repo_root "$BATS_TEST_TMPDIR/child"

  [ "$status" -eq 0 ]
  [ "$output" = "$REPO" ]
}

@test "nwe_repo_root fails for an empty cwd" {
  cd "$REPO"

  run nwe_repo_root ""

  [ "$status" -ne 0 ]
  [ "$output" = "" ]
}

@test "nwe_latest_default_commit fetches the default branch and prints its commit" {
  setup_stubs
  cd "$REPO"

  run nwe_latest_default_commit

  [ "$status" -eq 0 ]
  [ "$output" = "$ORIGIN_MAIN_SHA" ]
}
