REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

setup_stubs() {
  export FZF_STUB_DIR="$BATS_TEST_TMPDIR/fzf"
  export HERDR_STUB_DIR="$BATS_TEST_TMPDIR/herdr"
  export GH_STUB_DIR="$BATS_TEST_TMPDIR/gh"
  export HERDR_PLUGIN_CONFIG_DIR="$BATS_TEST_TMPDIR/config"
  mkdir -p "$FZF_STUB_DIR" "$HERDR_STUB_DIR" "$GH_STUB_DIR" "$HERDR_PLUGIN_CONFIG_DIR"
  : >"$FZF_STUB_DIR/queue"
  : >"$FZF_STUB_DIR/calls"
  : >"$HERDR_STUB_DIR/calls"
  : >"$GH_STUB_DIR/calls"
  cp "$BATS_TEST_DIRNAME/fixtures/issues.json" "$GH_STUB_DIR/issues.json"
  cp "$BATS_TEST_DIRNAME/fixtures/prs.json" "$GH_STUB_DIR/prs.json"
  export PATH="$BATS_TEST_DIRNAME/stubs:$PATH"
  export HERDR_BIN_PATH="$BATS_TEST_DIRNAME/stubs/herdr"
}

setup_git_repo() {
  export GIT_CONFIG_GLOBAL=/dev/null
  export GIT_CONFIG_NOSYSTEM=1
  export GIT_AUTHOR_NAME=test GIT_AUTHOR_EMAIL=test@example.com
  export GIT_COMMITTER_NAME=test GIT_COMMITTER_EMAIL=test@example.com
  local upstream="$BATS_TEST_TMPDIR/upstream" origin="$BATS_TEST_TMPDIR/origin.git"
  git init -q -b main "$upstream"
  git -C "$upstream" commit -q --allow-empty -m first
  git clone -q --bare "$upstream" "$origin"
  git -C "$upstream" remote add origin "$origin"
  git clone -q "$origin" "$BATS_TEST_TMPDIR/repo"
  git -C "$upstream" commit -q --allow-empty -m second
  git -C "$upstream" push -q origin main
  REPO="$(cd "$BATS_TEST_TMPDIR/repo" && pwd -P)"
  UPSTREAM="$upstream"
  ORIGIN_MAIN_SHA="$(git -C "$upstream" rev-parse HEAD)"
}

push_origin_branch() {
  git -C "$UPSTREAM" switch -q -c "$1" main
  git -C "$UPSTREAM" commit -q --allow-empty -m "$1"
  git -C "$UPSTREAM" push -q origin "$1"
  git -C "$UPSTREAM" switch -q main
}

fzf_will_select() {
  printf 'select\t%s\n' "$1" >>"$FZF_STUB_DIR/queue"
}

fzf_will_type() {
  printf 'type\t%s\n' "$1" >>"$FZF_STUB_DIR/queue"
}

fzf_will_accept() {
  printf 'accept\n' >>"$FZF_STUB_DIR/queue"
}

fzf_will_cancel() {
  printf 'cancel\n' >>"$FZF_STUB_DIR/queue"
}

fzf_will_fail() {
  printf 'fail\t%s\n' "$1" >>"$FZF_STUB_DIR/queue"
}

fzf_calls() {
  cat "$FZF_STUB_DIR/calls"
}

herdr_calls() {
  cat "$HERDR_STUB_DIR/calls"
}

write_config() {
  printf '%s\n' "$1" >"$HERDR_PLUGIN_CONFIG_DIR/config.json"
}

gh_calls() {
  cat "$GH_STUB_DIR/calls"
}

run_picker() {
  run "${NWE_TEST_BASH:-bash}" "$REPO_ROOT/bin/pick.sh" </dev/null
}

run_picker_from() {
  NWE_CONTEXT_JSON="$(jq -n --arg cwd "$1" '{focused_pane_cwd: $cwd}')"
  export NWE_CONTEXT_JSON
  run_picker
}
