#!/bin/zsh
launchctl bootout "gui/$(id -u)/com.kevintosh.spacewatch" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.kevintosh.spacewatch.plist"
rm -f "$HOME/.local/bin/spacewatch"
echo "Removed binary and watcher. Profiles remain in ~/Library/Application Support/SpaceWatch/Profiles"
