# Repository Guidelines

## Project Structure & Module Organization
- Core bootstrap lives in `oh-my-zsh.sh`; shared helpers sit in `lib/*.zsh`.
- Plugins reside in `plugins/<name>/` with `<name>.plugin.zsh` (and sometimes `_name` completion files); prefer adding custom or experimental plugins under `custom/plugins/` first.
- Themes live in `themes/*.zsh-theme`; preview links are in the wiki.
- Templates (notably `templates/zshrc.zsh-template`) seed new installations; keep defaults safe and minimal.
- User configuration lives in `~/.zshrc` and often carries extensive customizations; consult it when debugging load order or overrides.
- Runtime data goes to `cache/` and `log/`; keep tracked files clean and avoid committing user-specific output.

## Build, Test, and Development Commands
- Install/upgrade scaffolding: `tools/install.sh`, `tools/upgrade.sh`, `tools/uninstall.sh` for local validation; run with `zsh tools/install.sh` when testing changes.
- Quick load for iterative work: `ZSH=$PWD ZSH_CUSTOM=$PWD/custom zsh -f -c "source ./oh-my-zsh.sh"` to verify startup without user config.
- Syntax check a script: `zsh -n path/to/file.zsh` before sending a PR.

## Coding Style & Naming Conventions
- Shell scripts are zsh-first; prefer POSIX-compatible constructs unless zsh features add clear value.
- Indentation: 2 spaces; avoid tabs. Keep line length reasonable (~100 chars).
- Name plugins and themes in lowercase with hyphens/underscores matching existing patterns (e.g., `plugins/gitfast`, `themes/agnoster`).
- Files: plugin entrypoint is `<name>.plugin.zsh`; completion files start with `_`; themes end with `.zsh-theme`.
- Document user-facing functions, aliases, and variables inline; update plugin README files when behavior changes.

## Testing Guidelines
- No global test suite; rely on targeted checks: `zsh -n` for syntax and manual load via `zsh -f` with the plugin/theme enabled in a temporary `.zshrc`.
- Verify interactive behaviors (prompts, completions, aliases) in both macOS and Linux shells when feasible; capture regressions by comparing `set -x` traces before/after changes.
- Avoid slow startup regressions; measure with `time zsh -i -c exit` when adding new sourcing logic.

## Commit & Pull Request Guidelines
- Remotes: `origin` -> `https://github.com/nodoubleg/oh-my-zsh.git` (personal fork); `upstream` -> `https://github.com/ohmyzsh/ohmyzsh.git` (source of truth).
- Low-friction sync: keep it simple—`git fetch upstream` then `git merge upstream/master` into your working branch; avoid complex flows unless resolving conflicts. Rebase is optional if you prefer linear history.
- This is a personal fork; upstream `ohmyzsh/ohmyzsh` changes can be pulled/merged locally, but commits here are not intended to go upstream.
- Commits: short, imperative subjects (e.g., `fix plugin load order`); keep to one logical change; wrap body at 72 chars; reference issues in the body (`Fixes #1234`) when applicable.
- PRs: describe motivation, reproduction steps, and observed vs. expected behavior; link related issues; include screenshots or terminal captures for prompt/theme changes.
- For new plugins/themes, list added aliases/functions, required tools, and defaults; ensure `templates/zshrc.zsh-template` remains conservative and does not auto-enable new items.

## Security & Configuration Tips
- Never commit personal secrets, tokens, or machine-specific paths; sanitize examples in docs.
- Keep scripts resilient to unset variables and failing commands (`set -e` is not used globally, so guard critical steps explicitly).
- When touching auto-update logic or filesystem paths, test under both default `~/.oh-my-zsh` and a custom `ZSH` location to avoid clobbering user setups.

## Local Environment Notes
- The legacy gpg-agent bootstrap block in `~/.zshrc` is commented out for now. It previously pointed at a custom macOS gpg-agent install; we will revisit and reconfigure gpg-agent later, possibly via the upstream plugin.
- Per-machine helper scripts live under `custom/scripts/` (e.g., `custom/scripts/patch_zshrc.sh` to align legacy configs). This directory is intentionally outside the tracked core so upstream syncs never clobber local tooling.
- We intentionally do **not** check in a full `.zshrc` because some hosts carry machine- or role-specific values. Use the patch script when you need to bring another machine in line, but keep host-only bits in place.
- A separate dotfiles repo lives at `~/dotfiles`; always check with the user before modifying anything there, regardless of approval mode.
