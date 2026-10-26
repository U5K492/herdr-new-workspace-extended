#!/usr/bin/env bash
set -euo pipefail

demo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

exec env -i \
  HOME="$NWE_DEMO_HOME" \
  USER="${USER:-demo}" \
  PATH="$demo/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
  TERM="${TERM:-xterm-256color}" \
  COLORTERM=truecolor \
  LANG=en_US.UTF-8 \
  SHELL=/bin/zsh \
  herdr "$@"
