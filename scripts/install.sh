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

# Make sure plugin is visible in menu bar (helps on systems where new status items
# can end up hidden by default in Control Center preferences).
defaults write com.ameba.SwiftBar "NSStatusItem VisibleCC git-persona-bar.5s.sh" -bool true >/dev/null 2>&1 || true

echo "Installed plugin symlink:"
echo "  $PLUGIN_TARGET -> $PLUGIN_SOURCE"

echo "Set SwiftBar visibility flag for git-persona-bar.5s.sh"

# Soft restart SwiftBar to apply visibility + plugin scan immediately.
if pgrep -x "SwiftBar" >/dev/null 2>&1; then
  osascript -e 'tell application "SwiftBar" to quit' >/dev/null 2>&1 || true
  sleep 1
  open -a SwiftBar >/dev/null 2>&1 || true
  echo "Restarted SwiftBar"
fi

echo
if [ -f "$SWIFTBAR_DIR/git-profile.5s.sh" ]; then
  echo "Note: legacy plugin detected at $SWIFTBAR_DIR/git-profile.5s.sh"
  echo "You may see two similar menu icons until you remove/disable the old plugin."
  echo
fi

echo "Next steps:"
echo "1) Configure profiles in ~/.config/git-persona-bar/profiles.json"
echo "2) Optional wizard: $REPO_ROOT/scripts/add-profile.sh"
echo "3) If icon is still not visible, open SwiftBar and click Refresh All"
