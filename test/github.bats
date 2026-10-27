setup() {
  load helper
  setup_stubs
  source "$REPO_ROOT/lib/ui.sh"
  source "$REPO_ROOT/lib/config.sh"
  source "$REPO_ROOT/sources/github.sh"
}

@test "nwe_github_toggle_mine_key defaults to ctrl-o" {
  run nwe_github_toggle_mine_key

  [ "$output" = ctrl-o ]
}

@test "nwe_github_toggle_mine_key reads keys.toggle_assigned, the old name of keys.toggle_mine" {
  write_config '{"keys": {"toggle_assigned": "ctrl-t"}}'

  run nwe_github_toggle_mine_key

  [ "$output" = ctrl-t ]
}

@test "nwe_github_toggle_mine_key prefers keys.toggle_mine over keys.toggle_assigned" {
  write_config '{"keys": {"toggle_mine": "alt-m", "toggle_assigned": "ctrl-t"}}'

  run nwe_github_toggle_mine_key

  [ "$output" = alt-m ]
}
