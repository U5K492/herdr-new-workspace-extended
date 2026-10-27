setup() {
  load helper
  setup_stubs
  setup_git_repo
  write_config '{"agent": {"kind": "claude"}}'
  herdr_will_fail agent get '{"error":{"code":"agent_not_found","message":"agent target not found"}}'
}

created() {
  printf '{"result":{"type":"%s","workspace":{"workspace_id":"w9"},"root_pane":{"pane_id":"w9:p1"},"already_open":%s}}' "$1" "${2:-false}"
}

@test "a named workspace starts the configured agent in its first pane, named after the workspace" {
  herdr_will_return workspace create "$(created workspace_created)"
  fzf_will_select name
  fzf_will_type foo

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  wait_for_herdr_call "[agent][start]"
  [[ "$(herdr_calls)" == *"[agent][start][foo][--kind][claude][--pane][w9:p1]"* ]]
}

@test "a worktree workspace starts the agent named after its branch" {
  herdr_will_return worktree create "$(created worktree_created)"
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  wait_for_herdr_call "[agent][start]"
  [[ "$(herdr_calls)" == *"[agent][start][my-feature][--kind][claude][--pane][w9:p1]"* ]]
}

@test "a worktree that herdr opens anew starts the agent" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/wt" -b my-feature
  herdr_will_return worktree open "$(created worktree_opened false)"
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  wait_for_herdr_call "[agent][start]"
  [[ "$(herdr_calls)" == *"[agent][start][my-feature][--kind][claude][--pane][w9:p1]"* ]]
}

@test "a worktree already open in herdr gets no second agent" {
  git -C "$REPO" worktree add -q "$BATS_TEST_TMPDIR/wt" -b my-feature
  herdr_will_return worktree open "$(created worktree_opened true)"
  fzf_will_select branch
  fzf_will_type my-feature

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[worktree][open][--cwd][$REPO][--branch][my-feature][--focus]" ]
}

@test "without agent.kind no agent starts" {
  write_config '{}'
  herdr_will_return workspace create "$(created workspace_created)"
  fzf_will_select name
  fzf_will_type foo

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = "[workspace][create][--label][foo][--focus]" ]
}

@test "a failed start shows herdr's error in a notification" {
  herdr_will_return workspace create "$(created workspace_created)"
  herdr_will_fail agent start '{"error":{"code":"pane_not_found","message":"pane w9:p1 not found"}}'
  fzf_will_select name
  fzf_will_type foo

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  wait_for_herdr_call "[notification][show]"
  [[ "$(herdr_calls)" == *"[notification][show][Could not start claude][--body][pane w9:p1 not found]"* ]]
}

@test "an agent stopped at a startup prompt asks for an answer in the notification" {
  herdr_will_return workspace create "$(created workspace_created)"
  herdr_will_fail agent start '{"error":{"code":"agent_not_ready","message":"agent foo is blocked during startup and is not ready for prompts"}}'
  fzf_will_select name
  fzf_will_type foo

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  wait_for_herdr_call "[notification][show]"
  [[ "$(herdr_calls)" == *"[notification][show][claude is waiting for an answer][--body][agent foo is blocked during startup and is not ready for prompts]"* ]]
}

@test "an error that is not JSON is shown as it is" {
  write_config '{"agent": {"kind": "claud"}}'
  herdr_will_return workspace create "$(created workspace_created)"
  herdr_will_fail agent start "error: invalid value 'claud' for '--kind <KIND>'"
  fzf_will_select name
  fzf_will_type foo

  run_picker_from "$REPO"

  [ "$status" -eq 0 ]
  wait_for_herdr_call "[notification][show]"
  [[ "$(herdr_calls)" == *"[notification][show][Could not start claud][--body][error: invalid value 'claud' for '--kind <KIND>']"* ]]
}
