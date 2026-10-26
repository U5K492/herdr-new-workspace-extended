#!/usr/bin/env bash
set -euo pipefail

context="${HERDR_PLUGIN_CONTEXT_JSON:-}"
[ -n "$context" ] || context='{}'

exec "${HERDR_BIN_PATH:-herdr}" plugin pane open \
  --plugin "$HERDR_PLUGIN_ID" \
  --entrypoint picker \
  --env "NWE_CONTEXT_JSON=$context"
