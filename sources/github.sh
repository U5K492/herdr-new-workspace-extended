# shellcheck shell=bash

nwe_github_toggle_mine_key() {
  nwe_config '.keys.toggle_mine // .keys.toggle_assigned' ctrl-o
}
