# shellcheck shell=bash

nwe_choose() {
  local prompt="$1" selection status=0
  shift
  selection="$(fzf --delimiter "$(printf '\t')" --with-nth 2.. --prompt "$prompt" --layout reverse "$@")" || status=$?
  if [ "$status" -eq 2 ]; then
    nwe_notice "fzf exited with an error."
    return 1
  fi
  [ "$status" -eq 0 ] || return 1
  printf '%s\n' "${selection%%$'\t'*}"
}

nwe_menu() {
  printf '%s\n' "$1" | nwe_choose "New workspace> "
}

nwe_input() {
  local prompt="$1" default="$2" query status=0
  shift 2
  query="$(printf '' | fzf --print-query --query "$default" --prompt "$prompt" --layout reverse --info hidden "$@")" || status=$?
  if [ "$status" -ne 0 ] && [ "$status" -ne 1 ]; then
    return 1
  fi
  printf '%s\n' "${query%%$'\n'*}"
}

nwe_progress() {
  printf '%s\n' "$1" >&2
}

nwe_notice() {
  printf '%s\n\nPress any key to close.\n' "$1" >&2
  read -r -s -n 1 _ || true
}
