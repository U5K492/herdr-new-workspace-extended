REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup_stubs() {
  export FZF_STUB_DIR="$BATS_TEST_TMPDIR/fzf"
  export HERDR_STUB_DIR="$BATS_TEST_TMPDIR/herdr"
  mkdir -p "$FZF_STUB_DIR" "$HERDR_STUB_DIR"
  : >"$FZF_STUB_DIR/queue"
  : >"$FZF_STUB_DIR/calls"
  : >"$HERDR_STUB_DIR/calls"
  export PATH="$BATS_TEST_DIRNAME/stubs:$PATH"
  export HERDR_BIN_PATH="$BATS_TEST_DIRNAME/stubs/herdr"
}

fzf_will_select() {
  printf 'select\t%s\n' "$1" >>"$FZF_STUB_DIR/queue"
}

fzf_will_type() {
  printf 'type\t%s\n' "$1" >>"$FZF_STUB_DIR/queue"
}

fzf_will_cancel() {
  printf 'cancel\n' >>"$FZF_STUB_DIR/queue"
}

fzf_calls() {
  cat "$FZF_STUB_DIR/calls"
}

herdr_calls() {
  cat "$HERDR_STUB_DIR/calls"
}

run_picker() {
  run "${NWE_TEST_BASH:-bash}" "$REPO_ROOT/bin/pick.sh"
}
