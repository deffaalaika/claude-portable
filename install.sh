#!/bin/bash
# Install the global preferences (CLAUDE.md) and the android-field-notes skill into ~/.claude.
# Existing files are left alone unless --force is given; with --force they are backed up first.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
FORCE="${1:-}"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEST/skills"

place() { # place <src> <dest>
  local src="$1" dst="$2"
  if [ -e "$dst" ]; then
    if diff -rq "$src" "$dst" >/dev/null 2>&1; then
      echo "   ok   $dst (already up to date)"; return
    fi
    if [ "$FORCE" != "--force" ]; then
      echo "   skip $dst exists and differs. Merge it by hand, or re-run with --force"
      return
    fi
    mv "$dst" "$dst.bak-$STAMP"
    echo "   backup -> $dst.bak-$STAMP"
  fi
  cp -R "$src" "$dst"
  echo "   ok   $dst"
}

place "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"
place "$SRC/skills/android-field-notes" "$DEST/skills/android-field-notes"
