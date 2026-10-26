setup() {
  load helper
  setup_stubs
  source "$REPO_ROOT/lib/ui.sh"
}

@test "nwe_input returns the typed query even though fzf finds no match" {
  fzf_will_type bar

  run nwe_input "Name> " ""

  [ "$status" -eq 0 ]
  [ "$output" = bar ]
}

@test "nwe_input starts from the given default" {
  fzf_will_type 12-foo

  nwe_input "Branch> " "12-foo" >/dev/null

  [[ "$(fzf_calls)" == *"--query 12-foo"* ]]
}

@test "nwe_input fails when cancelled" {
  fzf_will_cancel

  run nwe_input "Name> " ""

  [ "$status" -ne 0 ]
  [ -z "$output" ]
}

@test "nwe_menu prints the key of the chosen item" {
  fzf_will_select issue

  run nwe_menu "$(printf 'name\tWith a name\nissue\tFrom an issue')"

  [ "$status" -eq 0 ]
  [ "$output" = issue ]
}

@test "nwe_menu fails when cancelled" {
  fzf_will_cancel

  run nwe_menu "$(printf 'name\tWith a name')"

  [ "$status" -ne 0 ]
  [ -z "$output" ]
}
