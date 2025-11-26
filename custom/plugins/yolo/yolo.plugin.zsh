# yolo plugin: commits every pending change with a single force push.
yolo() {
  local commit_msg="💩🔥🫠 YOLO ☄️💩💥"

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "yolo: not inside a git repository" >&2
    return 1
  fi

  git add -u || return 1

  local staged_untracked=0
  while IFS= read -r -d '' file; do
    git add -- "$file" || return 1
    staged_untracked=1
  done < <(git ls-files --others --exclude-standard -z)

  if git diff --cached --quiet; then
    echo "yolo: nothing to commit" >&2
    return 0
  fi

  if ! git commit -m "$commit_msg"; then
    echo "yolo: commit failed" >&2
    return 1
  fi

  if ! git push --force-with-lease "$@"; then
    echo "yolo: push failed" >&2
    return 1
  fi
}
