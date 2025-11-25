# Custom Scripts

Drop personal maintenance or patch scripts here. `custom/scripts` lives outside of the tracked OMZ tree, so upstream updates will never clobber it. These files are excluded from the main framework and only run when you explicitly invoke them.

## Included helpers

- `patch_zshrc.sh` — rewrites legacy `.zshrc` snippets (macOS/Linux plugin lists and the old pandoc completion block) to the current configuration. Run it manually on any machine that still has the outdated config; it creates a timestamped backup before applying changes.
