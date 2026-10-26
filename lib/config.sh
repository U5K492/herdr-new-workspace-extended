# shellcheck shell=bash

nwe_config() {
  local query="$1" default="$2" file value=""
  file="${HERDR_PLUGIN_CONFIG_DIR:-}/config.json"
  if [ -n "${HERDR_PLUGIN_CONFIG_DIR:-}" ] && [ -f "$file" ]; then
    value="$(jq -r "$query // empty" "$file")" || {
      nwe_notice "Could not read $file."
      return 1
    }
  fi
  printf '%s\n' "${value:-$default}"
}

nwe_toggle_mine_key() {
  nwe_config '.keys.toggle_mine // .keys.toggle_assigned' ctrl-o
}
