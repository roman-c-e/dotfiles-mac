# Dotfiles for macOS

## Packages with Homebrew Bundle

Install [Homebrew](https://brew.sh/) first, then run these commands from this
repository. Choose the profiles needed on each machine:

| File | Purpose |
| --- | --- |
| `Brewfile` | Shared CLI tools, Neovim, lazygit, mise, tmux/Mosh, and file previews |
| `brew/desktop.Brewfile` | cmux, fonts, OrbStack, desktop apps, and App Store apps |
| `brew/infrastructure.Brewfile` | Cloud, Kubernetes, Terraform/OpenTofu, and secrets tools |
| `brew/legacy.Brewfile` | Previous global runtimes/build tools and Ollama during migration |

```sh
# CLI environment, including on a remote development Mac
brew bundle install --file=Brewfile --no-upgrade

# Add the desktop environment on your workstation
brew bundle install --file=brew/desktop.Brewfile --no-upgrade

# Optional profiles
brew bundle install --file=brew/infrastructure.Brewfile --no-upgrade
brew bundle install --file=brew/legacy.Brewfile --no-upgrade
```

The profiles are additive: each optional file contains only its own additions.
The desktop profile includes the previous installer's large document/media apps,
including MacTeX; edit that profile if you want a smaller workstation setup.
App Store entries require sign-in and access to the apps (Magnet is paid).

Check a profile without installing packages:

```sh
brew bundle check --file=Brewfile --no-upgrade --verbose
brew bundle list --file=brew/desktop.Brewfile
```

`--no-upgrade` installs missing packages without upgrading installed ones. Omit it
when intentionally updating. Brewfiles describe package selections, not an exact
version lock. See [Homebrew Bundle documentation](https://docs.brew.sh/Brew-Bundle-and-Brewfile).

Do not run `brew bundle cleanup --force` against an individual profile: it can
remove packages belonging to other profiles or installed separately.

## Everyday terminal workflow

Open a new terminal to pick up the shell changes. `EDITOR` and `VISUAL` use
Neovim; `lg` opens lazygit with the repo-managed Mocha theme. `yazi` is a terminal
file browser with previews, useful for navigating files and opening them in Neovim.

### AI-assisted commit messages

In lazygit's **Files** panel, stage the desired files/hunks and press **Shift+G**.
The `ai-commit` script sends the staged diff to your authenticated Codex CLI,
opens the draft in `$VISUAL`/`$EDITOR` (Neovim by default), then displays it and
asks you to type `yes` before committing. Enter cancels; `:cq` in Neovim aborts.
It never stages files or pushes. Normal Git commit hooks and signing still apply.

```sh
ai-commit               # Generate, edit, and confirm
ai-commit --draft-only  # Print a draft without opening an editor or committing
```

Codex must already be installed and signed in. Generation uses an ephemeral,
read-only invocation in a temporary directory, with user configuration omitted
to avoid loading unrelated tools; authentication is retained. Set
`AI_COMMIT_MODEL` to select a model instead of the CLI default.
Only the staged diff is supplied, so repository-specific instructions and
unstaged changes are not included. Diffs over 200 KB use a staged-file summary
(up to 40 KB) and a patch preview (up to 12 KB per file, 160 KB total), with
omissions explicitly marked. Review these drafts for missing details.
If the staging area or HEAD changes during generation or
review, the script aborts so you can generate a fresh message.

The `cproj` launcher opens a new cmux workspace with three panes: an AI CLI on
the left, Neovim at the upper right, and a shell for builds/tests below it.
Run it from cmux while the app is open:

```sh
cproj                               # Fuzzy-pick a Git project under ~/Developer
cproj .                             # Focus this project's workspace, or create it
cproj --new .                       # Explicitly create another workspace
cproj --agent claude ~/path/to/repo  # Choose a different AI CLI
cproj --agent 'codex resume' .       # Pick a previous Codex session for this directory
cproj --agent 'codex resume --last' . # Resume the most recent matching session
cproj --root ~/Developer            # Search another project root
cproj --list                        # Print discovered repositories
cproj --dry-run .                   # Inspect the layout without opening anything
```

Set `CPROJ_ROOT` and `CPROJ_AGENT` in your environment to change the defaults.
For example, `export CPROJ_AGENT='codex resume'` makes the resume picker the
default for the current shell. Store persistent preferences in the private
configuration described below.
Agent commands support quoted arguments, but do not evaluate shell expressions.
The picker requires fd and fzf; layout generation uses jq. Discovery includes
Git worktrees, searches up to eight levels, and skips dependency/build folders.
The launcher searches all cmux windows for the project's canonical full path.
It focuses an existing local workspace, or creates one when no match exists.
Project identity is saved per workspace UUID under
`${XDG_STATE_HOME:-~/.local/state}/cproj/workspaces/`, outside the Git checkout.
It survives workspace renames, directory changes, and normal cmux restarts.
Managed workspace titles are prefixed with `⌘`, for example `⌘ dotfiles-mac`.
Generated `cproj:/full/project/path` and symbol-only descriptions are cleared;
custom descriptions are preserved for notes and can be edited without breaking reuse.
Older workspaces with an empty description can be adopted when their current
directory exactly matches. SSH workspaces are excluded from local matching.
If several match, a tagged workspace is preferred, then one with a custom name,
then a selected workspace. `--agent` applies only when creating a workspace;
use `--new --agent claude .` to open a second agent workspace.
Builds/tests are not started automatically. The shell pane is ready for the
project's existing commands. SSH workspaces can still be opened with `cmux ssh`;
`cproj` creates local workspaces.

### Sidebar groups and colors

The public launcher contains no project-specific roots or group names. Optional
private settings are read from `${PERSONAL_FILES:-~/.personal-files}/cproj.json`,
or the file named by `CPROJ_CONFIG`. Without that file, the launcher searches
`~/Developer`, starts `codex`, and leaves projects ungrouped. Environment variables
`CPROJ_ROOT`/`CPROJ_AGENT` and command-line options override private defaults.

Keep a configuration like this in your own private dotfiles repository:

```json
{
  "root": "~/Developer",
  "agent": "codex resume",
  "groups": [
    {
      "path": "~/Developer/example-team",
      "name": "Work",
      "color": "#89b4fa",
      "root": "~/Developer/example-team"
    }
  ]
}
```

Groups use the longest matching directory prefix. `root` inside a group is
optional and defaults to its `path`; multiple paths can share a group name.
New `cproj` workspaces appear directly below their group's header. Headers are
terminal workspaces at the configured group root. Matching groups are reused by
name within each window. Group colors/icons persist in cmux's local session state.
Keep work-only Brewfiles in your private repository as well.

Run `cproj --sync-sidebar` to apply the grouping/colors to existing local
workspaces and migrate old cproj descriptions without restarting their programs.
The command restores each window's selected workspace when finished.
Remote workspaces are excluded. Existing custom descriptions are kept;
group/color choices for these project families are reapplied by cproj.

Descriptions and notification-driven ordering remain enabled. cmux's current
ordering implementation moves a notified member directly below its group anchor
and also moves its unpinned group upward; this is not a strict most-recent-focus
sort. New workspaces created with the group + button also use top placement.

### Reopening projects after quitting cmux

cmux automatically saves and restores open windows, workspaces, pane layouts,
working directories, and browser state on normal launch. There is no separate
`cproj save` step. The local identity records match the saved workspace IDs, so reuse
continues after relaunch. Close an individual workspace to remove it from the
set of open projects; quit the app with workspaces open to restore them later.

Restoring a workspace does not checkpoint running processes or unsaved Neovim
buffers. Save editor changes before quitting; reopen Neovim and restart dev
servers as needed. Supported AI sessions can resume if cmux captured their native
session IDs and **Resume Agent Sessions on Reopen** is enabled. Agent hooks can
be installed with `cmux hooks setup --agent codex` (or the appropriate agent).
See [cmux session restore](https://cmux.com/docs/session-restore).
For manual recovery, use **History > Restore Previous App Launch** or
`cmux restore-session`; this is separate from normal `cproj` reuse.

Shell startup deduplicates PATH, tolerates optional tools being absent, and
loads Angular completion on first use instead of invoking Angular in every pane.
mise activates automatically when installed. The shell no longer pins Java 21:
declare the required versions in each project's `mise.toml`, then use
`mise trust` and `mise install` for projects you trust. Existing Homebrew runtimes
remain available when no mise version is selected. No project versions are
selected globally by these dotfiles.

## Migration notes

- cmux manages desktop terminals and workspaces; lazygit handles Git review.
  Kitty, Zellij, GitUI, and Postman are omitted from the Brewfiles. Existing
  installations and their dotfiles are not removed.
- OrbStack reflects the current machine and replaces the old installer's Docker
  Desktop selection. IntelliJ and VS Code are omitted from the new profiles.
- ComicTagger and RAR are commented out because their Homebrew casks were disabled
  on 2026-09-01; they would prevent a clean desktop install.
- The shared profile includes mise and the shell activates it when available.
  Project `mise.toml` files still need version declarations. Existing projects
  can use the legacy runtimes in the meantime.
- Installing Neovim does not migrate the existing configuration to LazyVim.
  The existing Neovim configuration remains in use, with its broken NERDTree
  Git-status extension disabled; gitsigns still shows Git changes.
- AI agent CLIs keep their existing installation methods for now; these Brewfiles
  do not reinstall agents through a second package manager.
- Full Xcode and simulator runtimes must be installed separately on a Mac that
  builds/runs iOS apps. Use Screen Sharing to view its Simulator remotely.

## Existing setup scripts

`install.sh` is the legacy all-in-one installer, including package installs and
macOS preferences. Use the Brewfiles above for packages instead; the script has
not yet been migrated.

`install-config.sh` works from any checkout location and links only the files
listed in `config-links.txt`, plus `~/.zshrc`:

```sh
zsh ./install-config.sh --dry-run
zsh ./install-config.sh
```

It preserves unrelated files, skips existing correct links, and backs up replaced
files and links under `~/.local/state/dotfiles/backups/install.*`. Each numbered
backup contains the original path relative to your home directory.
If `~/.config` (or a managed parent directory) is a symlink, it copies the existing
contents into a real directory before linking individual managed files. This
keeps new application state outside the checkout. Existing state in the checkout
is retained; ignore rules cover the known local state and backup files.
Add new shared configuration files to `config-links.txt` before rerunning the
installer. The shell configuration currently uses `~/.config` explicitly.

The installer does not download packages or plugin managers. Use the Brewfiles
for packages; existing Zap and Neovim plugin installations are preserved.

Parsec can still be installed separately if needed.

# Evaluate
## Aerospace 
Working mostly
- Autoraise missing
- Issues with multiple monitors
- Intellij Bug
## Sketchybar
does not work with magnet because gap on top
items not clickable, but this could be better because avoidance of mouse/trackpad
