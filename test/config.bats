setup() {
  load helper
  setup_stubs
  source "$REPO_ROOT/lib/ui.sh"
  source "$REPO_ROOT/lib/config.sh"
}

@test "nwe_config reads the value from config.json" {
  write_config '{"keys": {"toggle_assigned": "alt-m"}}'

  run nwe_config .keys.toggle_assigned ctrl-o

  [ "$status" -eq 0 ]
  [ "$output" = alt-m ]
}

@test "nwe_config falls back to the default when config.json lacks the setting" {
  write_config '{}'

  run nwe_config .keys.toggle_assigned ctrl-o

  [ "$output" = ctrl-o ]
}

@test "nwe_config falls back to the default without config.json" {
  run nwe_config .keys.toggle_assigned ctrl-o

  [ "$output" = ctrl-o ]
}

@test "nwe_config falls back to the default outside herdr" {
  unset HERDR_PLUGIN_CONFIG_DIR

  run nwe_config .keys.toggle_assigned ctrl-o

  [ "$output" = ctrl-o ]
}

@test "nwe_config shows the error and fails for a broken config.json" {
  write_config '{"keys":'

  run nwe_config .keys.toggle_assigned ctrl-o </dev/null

  [ "$status" -ne 0 ]
  [[ "$output" == *"Could not read $HERDR_PLUGIN_CONFIG_DIR/config.json."* ]]
  [[ "$output" == *"Press any key to close."* ]]
}
