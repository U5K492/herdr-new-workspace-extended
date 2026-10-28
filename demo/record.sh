#!/usr/bin/env bash
set -euo pipefail

demo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$demo")"

NWE_DEMO_HOME="$(cd "$(mktemp -d "${TMPDIR:-/tmp}/nwe-demo.XXXXXX")" && pwd -P)"
export NWE_DEMO_HOME
export NWE_DEMO_HERDR="$demo/herdr.sh"

cleanup() {
  "$NWE_DEMO_HERDR" server stop >/dev/null 2>&1 || true
  rm -rf "$NWE_DEMO_HOME"
}
trap cleanup EXIT

export GIT_AUTHOR_NAME=demo GIT_AUTHOR_EMAIL=demo@example.com
export GIT_COMMITTER_NAME=demo GIT_COMMITTER_EMAIL=demo@example.com
export GIT_CONFIG_GLOBAL=/dev/null

origin="$NWE_DEMO_HOME/.origin/acme-app.git"
clone="$NWE_DEMO_HOME/acme-app"
git init --quiet --bare --initial-branch main "$origin"
git clone --quiet "$origin" "$clone" 2>/dev/null
git -C "$clone" symbolic-ref HEAD refs/heads/main
mkdir -p "$clone/src"
printf '# acme-app\n' >"$clone/README.md"
printf 'export const theme = "light";\n' >"$clone/src/settings.ts"
git -C "$clone" add .
git -C "$clone" commit --quiet -m "feat: add the settings page"
git -C "$clone" push --quiet origin main
for branch in feat/cache-api fix/flaky-login; do
  git -C "$clone" switch --quiet --create "$branch" main
  git -C "$clone" commit --quiet --allow-empty -m "wip: $branch"
  git -C "$clone" push --quiet origin "$branch"
  git -C "$clone" switch --quiet main
  git -C "$clone" branch --quiet -D "$branch"
done

mkdir -p "$NWE_DEMO_HOME/.config/herdr"
cat >"$NWE_DEMO_HOME/.config/herdr/config.toml" <<'EOF'
onboarding = false

[update]
version_check = false
manifest_check = false

[ui]
sidebar_width = 34

[[keys.command]]
key = "prefix+shift+n"
type = "plugin_action"
command = "u5k492.new-workspace-extended.new"
description = "new workspace (extended)"
EOF
printf "PROMPT='%%F{blue}%%~%%f %%# '\n" >"$NWE_DEMO_HOME/.zshrc"
"$NWE_DEMO_HERDR" plugin link "$root" >/dev/null
config="$NWE_DEMO_HOME/.config/herdr/plugins/config/u5k492.new-workspace-extended"
mkdir -p "$config"
printf '{"agent": {"kind": "claude"}}\n' >"$config/config.json"

mkdir -p "$NWE_DEMO_HOME/.local/bin"
ln -s "$(command -v claude)" "$NWE_DEMO_HOME/.local/bin/claude"
worktrees="$NWE_DEMO_HOME/.herdr/worktrees/acme-app"
jq -n \
  --arg version "$(claude --version | cut -d' ' -f1)" \
  --args '{
    hasCompletedOnboarding: true,
    lastOnboardingVersion: $version,
    lastReleaseNotesSeen: $version,
    theme: "dark",
    hasSeenAutoDefaultNotice: true,
    projects: ($ARGS.positional | map({key: ., value: {hasTrustDialogAccepted: true}}) | from_entries)
  }' \
  "$clone" "$worktrees/42-add-a-dark-mode-toggle" "$worktrees/feat-cache-api" "$worktrees/chore-bump-deps" \
  >"$NWE_DEMO_HOME/.claude.json"

cd "$root"
vhs "$demo/demo.tape"
