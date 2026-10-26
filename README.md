# herdr-new-workspace-extended

A [herdr](https://herdr.dev) plugin that extends **new workspace**. Press the new workspace key and pick how to start:

- **With a name**: create a regular workspace, like the built-in command
- **From a GitHub issue** (planned): pick an open issue with fzf, confirm a branch name, and open a worktree workspace
- **From a GitHub pull request** (planned): pick an open pull request and open a worktree workspace on its branch

> Status: early development. Only "With a name" works today.

## Requirements

- herdr 0.9.5 or later
- bash
- [fzf](https://github.com/junegunn/fzf)

## Setup

1. Install the plugin:

   ```sh
   herdr plugin install U5K492/herdr-new-workspace-extended
   ```

2. Bind the new workspace key to the plugin in `~/.config/herdr/config.toml`, and move the built-in command to another key so you can still reach it:

   ```toml
   [keys]
   new_workspace = "prefix+ctrl+n"

   [[keys.command]]
   key = "prefix+shift+n"
   type = "plugin_action"
   command = "u5k492.new-workspace-extended.new"
   description = "new workspace (extended)"
   ```

   If your config still sets `new_workspace = "prefix+shift+n"`, herdr keeps the built-in binding and disables this one.

3. Reload the config:

   ```sh
   herdr server reload-config
   ```

## Development

```sh
mise install
herdr plugin link "$PWD"
bats test
NWE_TEST_BASH=/bin/bash bats test/new_workspace.bats
shellcheck bin/*.sh lib/*.sh test/stubs/*
```

`mise install` installs the versions of bats and shellcheck pinned in `mise.toml`. Without mise, use `brew install bats-core shellcheck`.

The popup runs `bash` from the herdr server's `PATH`, which can be macOS's `/bin/bash` 3.2. Keep scripts compatible with bash 3.2, and run the specs with `NWE_TEST_BASH=/bin/bash` to check.

### Layout

- `bin/open-picker.sh`: the `new` action. Opens the picker popup and passes the invocation context to it
- `bin/pick.sh`: runs inside the popup
- `lib/`: functions sourced by `bin/pick.sh`
- `test/`: bats specs. `test/stubs/` fakes fzf and herdr

### The `nwe` prefix

`nwe` stands for **N**ew **W**orkspace **E**xtended.
Bash has no namespaces, and the files in `lib/` are sourced into the same shell.
To avoid clashing with functions and variables from your shell or from herdr (`HERDR_*`), every function this plugin defines is named `nwe_*`, and every environment variable is named `NWE_*`.

## License

[MIT](LICENSE)
