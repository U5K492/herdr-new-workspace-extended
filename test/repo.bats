setup() {
  load helper
  setup_git_repo
  source "$REPO_ROOT/lib/repo.sh"
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

@test "nwe_fetch_origin_commit fetches the branch from origin and prints its commit" {
  cd "$REPO"

  run nwe_fetch_origin_commit main

  [ "$status" -eq 0 ]
  [ "$output" = "$ORIGIN_MAIN_SHA" ]
}

@test "nwe_has_worktree finds a linked worktree of the branch" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/child" -b child

  run nwe_has_worktree "$REPO" child

  [ "$status" -eq 0 ]
}

@test "nwe_has_worktree counts the main checkout" {
  run nwe_has_worktree "$REPO" main

  [ "$status" -eq 0 ]
}

@test "nwe_has_worktree fails for a branch without a worktree" {
  git -C "$REPO" branch -q lonely

  run nwe_has_worktree "$REPO" lonely

  [ "$status" -ne 0 ]
}

@test "nwe_has_origin succeeds for a clone" {
  run nwe_has_origin "$REPO"

  [ "$status" -eq 0 ]
}

@test "nwe_has_origin fails without an origin remote" {
  git -C "$REPO" remote remove origin

  run nwe_has_origin "$REPO"

  [ "$status" -ne 0 ]
}
