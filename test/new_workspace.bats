setup() {
  load helper
  setup_stubs
}

@test "the action opens the picker popup with the invocation context" {
  run env HERDR_PLUGIN_ID=u5k492.new-workspace-extended \
    HERDR_PLUGIN_CONTEXT_JSON='{"workspace_id":"w1"}' \
    "${NWE_TEST_BASH:-bash}" "$REPO_ROOT/bin/open-picker.sh"

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = '[plugin][pane][open][--plugin][u5k492.new-workspace-extended][--entrypoint][picker][--env][NWE_CONTEXT_JSON={"workspace_id":"w1"}]' ]
}

@test "choosing a name creates a labeled workspace and focuses it" {
  fzf_will_select name
  fzf_will_type foo

  run_picker

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = '[workspace][create][--label][foo][--focus]' ]
}

@test "a name with spaces is passed as one label" {
  fzf_will_select name
  fzf_will_type "my feature"

  run_picker

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = '[workspace][create][--label][my feature][--focus]' ]
}

@test "confirming an empty name creates an unlabeled workspace" {
  fzf_will_select name
  fzf_will_type ""

  run_picker

  [ "$status" -eq 0 ]
  [ "$(herdr_calls)" = '[workspace][create][--focus]' ]
}

@test "escaping the menu creates nothing" {
  fzf_will_cancel

  run_picker

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}

@test "escaping the name input creates nothing" {
  fzf_will_select name
  fzf_will_cancel

  run_picker

  [ "$status" -eq 0 ]
  [ -z "$(herdr_calls)" ]
}
