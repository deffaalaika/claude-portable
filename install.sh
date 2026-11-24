#!/bin/bash
# Pasang aturan global + skill android-field-notes ke ~/.claude
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
mkdir -p "$DEST/skills"

if [ -e "$DEST/CLAUDE.md" ]; then
  echo "~/.claude/CLAUDE.md sudah ada -> tidak ditimpa. Gabungkan manual dari $SRC/CLAUDE.md"
else
  cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md" && echo "OK  ~/.claude/CLAUDE.md"
fi

if [ -e "$DEST/skills/android-field-notes" ]; then
  echo "Skill android-field-notes sudah ada -> tidak ditimpa"
else
  cp -R "$SRC/skills/android-field-notes" "$DEST/skills/" && echo "OK  ~/.claude/skills/android-field-notes"
fi
