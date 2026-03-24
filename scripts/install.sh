#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_SOURCE="$REPO_ROOT/git-persona-bar.5s.sh"

if [ ! -f "$PLUGIN_SOURCE" ]; then
  echo "Plugin script not found: $PLUGIN_SOURCE"
  exit 1
fi

SWIFTBAR_DIR="$(defaults read com.ameba.SwiftBar PluginDirectory 2>/dev/null || true)"
if [ -z "$SWIFTBAR_DIR" ]; then
  SWIFTBAR_DIR="$HOME/Library/Application Support/SwiftBar"
fi

mkdir -p "$SWIFTBAR_DIR"
chmod +x "$PLUGIN_SOURCE"

PLUGIN_TARGET="$SWIFTBAR_DIR/git-persona-bar.5s.sh"

if [ -L "$PLUGIN_TARGET" ] || [ -f "$PLUGIN_TARGET" ]; then
  rm -f "$PLUGIN_TARGET"
fi

ln -s "$PLUGIN_SOURCE" "$PLUGIN_TARGET"

echo "Installed plugin symlink:"
echo "  $PLUGIN_TARGET -> $PLUGIN_SOURCE"
echo
echo "Next steps:"
echo "1) Open SwiftBar and refresh plugins"
echo "2) Configure profiles in ~/.config/git-persona-bar/profiles.json"
echo "3) Optional wizard: $REPO_ROOT/scripts/add-profile.sh"
