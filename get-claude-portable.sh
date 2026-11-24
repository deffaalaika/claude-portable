#!/bin/bash
# Download the claude-portable package from this repo's GitHub Release, verify it,
# unzip it and install it into ~/.claude (no GitHub login needed).
#
# Usage:
#   bash get-claude-portable.sh                 # download into ./claude-portable-download, then install
#   bash get-claude-portable.sh <dir>           # use files already downloaded into <dir>
#   bash get-claude-portable.sh [<dir>] --force # also replace existing files (old ones are backed up)
set -euo pipefail

REPO="deffaalaika/claude-portable"
BASE="https://github.com/$REPO/releases/latest/download"
ZIP="claude-portable.zip"

FORCE=""
DIR=""
for a in "$@"; do
  case "$a" in
    --force) FORCE="--force" ;;
    *) DIR="$a" ;;
  esac
done
DIR="${DIR:-$PWD/claude-portable-download}"
mkdir -p "$DIR"
cd "$DIR"

info() { printf '\033[36m==> %s\033[0m\n' "$*"; }
die()  { printf '\033[31m%s\033[0m\n' "$*"; exit 1; }

# 1. Checksums + package
for f in SHA256SUMS "$ZIP"; do
  if [ ! -f "$f" ]; then
    info "Downloading $f"
    curl -fL --retry 5 --retry-delay 3 -o "$f" "$BASE/$f"
  fi
done

# 2. Verify
want="$(grep " $ZIP\$" SHA256SUMS | awk '{print $1}')"
[ -n "$want" ] || die "No checksum for $ZIP in SHA256SUMS"
got="$(shasum -a 256 "$ZIP" | awk '{print $1}')"
if [ "$got" != "$want" ]; then
  rm -f "$ZIP" SHA256SUMS
  die "Checksum mismatch for $ZIP. It was deleted; run this script again."
fi
echo "   ok   $ZIP"

# 3. Unzip + install
info "Unzipping"
rm -rf claude-portable
unzip -q "$ZIP"
bash claude-portable/install.sh $FORCE

echo
echo "Done. Start a new Claude Code session. You can now delete: $DIR"
