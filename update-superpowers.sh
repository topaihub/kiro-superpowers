#!/bin/bash
set -e

KIRO_DIR="$HOME/.kiro"

if [ ! -d "$KIRO_DIR/superpowers/.git" ]; then
  echo "❌ superpowers submodule not found. Run initial setup first."
  exit 1
fi

cd "$KIRO_DIR"
echo "🔄 Updating superpowers..."
git submodule update --remote superpowers

if git diff --quiet superpowers; then
  echo "✅ Already up to date."
else
  git add superpowers
  git commit -m "update superpowers to $(cd superpowers && git rev-parse --short HEAD)"
  echo "✅ Updated and committed. Run 'cd ~/.kiro && git push' to sync."
fi
