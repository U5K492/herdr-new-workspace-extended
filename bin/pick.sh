#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/ui.sh
source "$root/lib/ui.sh"
# shellcheck source=../lib/create.sh
source "$root/lib/create.sh"

choice="$(nwe_menu "$(printf 'name\tNew workspace with a name')")" || exit 0

case "$choice" in
name)
  name="$(nwe_input "Workspace name> " "")" || exit 0
  nwe_create_named_workspace "$name"
  ;;
esac
