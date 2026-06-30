#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/bin"
PLUGIN_DIR="${SWIFTBAR_PLUGIN_DIR:-$HOME/Library/Application Support/SwiftBar/Plugins}"
ENABLE_AUTOSTART="false"

for arg in "$@"; do
  case "$arg" in
    --autostart) ENABLE_AUTOSTART="true" ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

mkdir -p "$BIN_DIR" "$PLUGIN_DIR"
cp "$ROOT_DIR/bin/fiberbar" "$BIN_DIR/fiberbar"
chmod +x "$BIN_DIR/fiberbar"
cp "$ROOT_DIR/swiftbar/fiberbar.5s.sh" "$PLUGIN_DIR/fiberbar.5s.sh"
chmod +x "$PLUGIN_DIR/fiberbar.5s.sh"

"$BIN_DIR/fiberbar" print-config >/dev/null

echo "Installed fiberbar to $BIN_DIR/fiberbar"
echo "Installed SwiftBar plugin to $PLUGIN_DIR/fiberbar.5s.sh"
echo "Run: $BIN_DIR/fiberbar configure"

if "$BIN_DIR/fiberbar" passwordless-status | grep -q '^enabled$'; then
  FIBERBAR_USER="$USER" \
    FIBERBAR_HOME="$HOME" \
    FIBERBAR_CONFIG="${FIBERBAR_CONFIG:-$HOME/.config/fiberbar/config}" \
    FIBERBAR_SOURCE_SCRIPT="$BIN_DIR/fiberbar" \
    sudo --preserve-env=FIBERBAR_USER,FIBERBAR_HOME,FIBERBAR_CONFIG,FIBERBAR_SOURCE_SCRIPT \
      /usr/local/sbin/fiberbar-root install-helper-root >/dev/null
  echo "Updated passwordless root helper."
else
  echo "Passwordless root helper was not updated. Enable it from the menu if needed."
fi

if [[ "$ENABLE_AUTOSTART" == "true" ]]; then
  mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs/FiberBar"
  cat > "$HOME/Library/LaunchAgents/com.fiberbar.swiftbar-autostart.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.fiberbar.swiftbar-autostart</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/open</string>
    <string>-a</string>
    <string>SwiftBar</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>LaunchOnlyOnce</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$HOME/Library/Logs/FiberBar/swiftbar-autostart.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/FiberBar/swiftbar-autostart.err.log</string>
</dict>
</plist>
EOF
  plutil -lint "$HOME/Library/LaunchAgents/com.fiberbar.swiftbar-autostart.plist" >/dev/null
  launchctl unload "$HOME/Library/LaunchAgents/com.fiberbar.swiftbar-autostart.plist" 2>/dev/null || true
  launchctl load "$HOME/Library/LaunchAgents/com.fiberbar.swiftbar-autostart.plist"
  echo "Enabled SwiftBar autostart via LaunchAgent."
fi
