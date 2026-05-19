# Codex Here

Local VS Code companion extension for exact `` `codex-here` `` comments.

When a matching comment appears in the current file, the extension shows an
`Open Codex Here` CodeLens. Clicking it writes a focused prompt to
`/tmp/codex-here/prompts/`, creates or reuses the `codex-here` tmux session,
opens a new tmux window for the task, and attaches a single Ghostty window when
no Ghostty tmux client is already attached.

By default, Codex Here includes the project prompt at
`prompts/.codex-here.md`.

## Local install

Install `tmux` first, then expose this directory to VS Code as a local
extension. One simple option is a symlink:

```sh
ln -s /home/reshi/dud/tools/vscode-codex-here \
  ~/.vscode/extensions/codex-here-local
```

Reload VS Code after creating the link.

Node/npm are not needed for this no-build version. If a future pass adds tests,
packaging, or TypeScript, set up Node/npm as a separate work item.
