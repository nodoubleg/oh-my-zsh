#!/usr/bin/env bash
set -euo pipefail

ZSHRC=${1:-"$HOME/.zshrc"}
if [[ ! -f "$ZSHRC" ]]; then
  echo "Error: $ZSHRC not found" >&2
  exit 1
fi

tmp=$(mktemp "${TMPDIR:-/tmp}/zshrc_patch.XXXXXX")
cleanup() {
  rm -f "$tmp"
}
trap cleanup EXIT

python3 - "$ZSHRC" "$tmp" <<'PY'
import pathlib
import re
import sys

src = pathlib.Path(sys.argv[1])
tmp_path = pathlib.Path(sys.argv[2])
text = src.read_text()
original = text
messages = []

uname_pattern = re.compile(
    r'uname=\$\(uname\)\s*\n'
    r'if \[\[ \$\{uname\}x -eq Darnwinx \]\]\s*\n'
    r'then\n'
    r'.*?'
    r'elif \[\[ \$\{uname\}x -eq Linuxx \]\]\s*\n'
    r'then\n'
    r'.*?'
    r'fi',
    re.S,
)
uname_replacement = """uname=$(uname)\nif [[ $uname == \"Darwin\" ]]\nthen\n  plugins=(git macos z hex2dec pandoc pwgen colored-man-pages safe-paste man brew)\n  eval \"$(/opt/homebrew/bin/brew shellenv)\"\n  unset LSCOLORS\n  source $ZSH/oh-my-zsh.sh\n  alias ls=\"/opt/homebrew/bin/gls --color=tty\"\n  alias kmdns=\"sudo killall -9 mDNSResponder\"\n  source /Users/gmason/.iterm2_shell_integration.zsh\n  # Various paths\n  export PATH=/Users/gmason/bin:/usr/local/sbin:/usr/local/bin:$PATH\n  alias gnubin='export PATH=\"/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH\"'\nelif [[ $uname == \"Linux\" ]]\nthen\n  plugins=(pandoc git ubuntu hex2dec pwgen colored-man-pages safe-paste man)\n  alias open='xdg-open 2>/dev/null'\nfi\n"""
text, count = uname_pattern.subn(uname_replacement, text, count=1)
if count:
  messages.append("Updated uname/os-specific block")

pandoc_pattern = re.compile(r"\n# set up pandoc tab-complete.*?\nfi\n", re.S)
text, count = pandoc_pattern.subn("\n", text, count=1)
if count:
  messages.append("Removed manual pandoc completion block")

tmp_path.write_text(text)
for msg in messages:
  print(msg)
PY

if cmp -s "$tmp" "$ZSHRC"; then
  echo "No changes needed; $ZSHRC already matches." >&2
else
  backup="$ZSHRC.pre_patch.$(date +%Y%m%d%H%M%S)"
  cp "$ZSHRC" "$backup"
  mv "$tmp" "$ZSHRC"
  trap - EXIT
  rm -f "$tmp"
  echo "Patched $ZSHRC. Backup saved to $backup."
  exit 0
fi
