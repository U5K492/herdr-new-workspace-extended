Output demo/demo.gif

Set Shell bash
Set FontSize 15
Set Width 1280
Set Height 640
Set Padding 16
Set Theme "Catppuccin Mocha"
Set TypingSpeed 120ms

Hide
Type 'cd "$NWE_DEMO_HOME/acme-app" && exec "$NWE_DEMO_HERDR"'
Enter
Wait+Screen /acme-app %/
Show
Sleep 1.5s

Ctrl+B
Type "N"
Wait+Screen /New worktree with a branch name/
Sleep 1s
Enter
Wait+Screen /Workspace name>/
Sleep 800ms
Type "notes"
Sleep 800ms
Enter
Wait+Screen@20s /(?m)~.acme-app *$/
Sleep 2.5s

Ctrl+B
Type "N"
Wait+Screen /From a GitHub issue/
Sleep 1s
Down 2
Sleep 500ms
Enter
Wait+Screen /Issue>/
Sleep 1.5s
Ctrl+O
Wait+Screen /My issue>/
Sleep 1.5s
Type "dark"
Sleep 1s
Enter
Wait+Screen /Branch>/
Sleep 1.5s
Enter
Wait+Screen@20s /(?m)acme-app.42-add-a-dark-mode-toggle *$/
Sleep 2.5s

Ctrl+B
Type "N"
Wait+Screen /From a GitHub pull request/
Sleep 1s
Down 3
Sleep 500ms
Enter
Wait+Screen /Pull request>/
Sleep 1.5s
Ctrl+R
Wait+Screen /Review request>/
Sleep 1.5s
Enter
Wait+Screen@20s /(?m)acme-app.feat-cache-api *$/
Sleep 2.5s

Ctrl+B
Type "N"
Wait+Screen /New worktree with a branch name/
Sleep 1s
Down 1
Sleep 500ms
Enter
Wait+Screen /Branch>/
Sleep 1s
Type "chore/bump-deps"
Sleep 800ms
Enter
Wait+Screen@20s /(?m)acme-app.chore-bump-deps *$/
Sleep 2.5s

Ctrl+B
Type "N"
Wait+Screen /From a GitHub pull request/
Sleep 1s
Down 3
Sleep 500ms
Enter
Wait+Screen /Pull request>/
Sleep 1.5s
Enter
Wait+Screen /(?m)acme-app.feat-cache-api *$/
Sleep 3s
