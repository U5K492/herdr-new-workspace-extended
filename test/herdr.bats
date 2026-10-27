setup() {
  load helper
  source "$REPO_ROOT/lib/herdr.sh"
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
