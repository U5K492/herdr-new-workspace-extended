setup() {
  load helper
  setup_stubs
  source "$REPO_ROOT/lib/herdr.sh"
  herdr_will_fail agent get '{"error":{"code":"agent_not_found","message":"agent target not found"}}'
}

@test "nwe_agent_name lowercases the name and turns what herdr rejects into hyphens" {
  run nwe_agent_name claude "My Feature/日本語" w9

  [ "$output" = my-feature ]
}

@test "nwe_agent_name puts the kind in front of a name that does not start with a letter" {
  run nwe_agent_name claude 12-add-login-page w9

  [ "$output" = claude-12-add-login-page ]
}

@test "nwe_agent_name falls back to the kind without a name" {
  run nwe_agent_name claude "" w9

  [ "$output" = claude ]
}

@test "nwe_agent_name keeps the first 32 characters" {
  run nwe_agent_name claude a-branch-name-that-is-longer-than-the-limit w9

  [ "$output" = a-branch-name-that-is-longer-tha ]
}

@test "nwe_agent_name adds the workspace id when another agent has the name" {
  herdr_will_return agent get '{"result":{"type":"agent_info"}}'

  run nwe_agent_name claude foo w1H

  [ "$output" = foo-w1h ]
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
