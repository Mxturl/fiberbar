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
mkdir -p "$HOME/.config/macsstp"
if [[ ! -f "$HOME/.config/macsstp/config" && -f "$HOME/.config/fiberbar/config" ]]; then
  cp "$HOME/.config/fiberbar/config" "$HOME/.config/macsstp/config"
  perl -0pi -e 's/FIBERBAR/MACSSTP/g; s/FiberBar/MacSSTP/g; s/fiberbar/macsstp/g' "$HOME/.config/macsstp/config"
  echo "Migrated legacy config to $HOME/.config/macsstp/config"
fi
cp "$ROOT_DIR/bin/macsstp" "$BIN_DIR/macsstp"
chmod +x "$BIN_DIR/macsstp"
cp "$ROOT_DIR/bin/fiberbar" "$BIN_DIR/fiberbar"
chmod +x "$BIN_DIR/fiberbar"
cp "$ROOT_DIR/swiftbar/macsstp.5s.sh" "$PLUGIN_DIR/macsstp.5s.sh"
chmod +x "$PLUGIN_DIR/macsstp.5s.sh"
if [[ -f "$PLUGIN_DIR/fiberbar.5s.sh" ]]; then
  mv "$PLUGIN_DIR/fiberbar.5s.sh" "$PLUGIN_DIR/fiberbar.5s.sh.disabled"
fi

"$BIN_DIR/macsstp" print-config >/dev/null

echo "Installed macsstp to $BIN_DIR/macsstp"
echo "Installed fiberbar compatibility wrapper to $BIN_DIR/fiberbar"
echo "Installed SwiftBar plugin to $PLUGIN_DIR/macsstp.5s.sh"
echo "Run: $BIN_DIR/macsstp configure"

if [[ -x /usr/local/sbin/macsstp-root ]] && sudo -n /usr/local/sbin/macsstp-root status >/dev/null 2>&1; then
  MACSSTP_USER="$USER" \
    MACSSTP_HOME="$HOME" \
    MACSSTP_CONFIG="${MACSSTP_CONFIG:-$HOME/.config/macsstp/config}" \
    MACSSTP_SOURCE_SCRIPT="$BIN_DIR/macsstp" \
    sudo --preserve-env=MACSSTP_USER,MACSSTP_HOME,MACSSTP_CONFIG,MACSSTP_SOURCE_SCRIPT \
      /usr/local/sbin/macsstp-root install-helper-root >/dev/null
  echo "Updated passwordless root helper."
else
  echo "Passwordless root helper was not updated. Enable it from the menu if needed."
fi

if [[ "$ENABLE_AUTOSTART" == "true" ]]; then
  mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs/MacSSTP"
  cat > "$HOME/Library/LaunchAgents/com.macsstp.swiftbar-autostart.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.macsstp.swiftbar-autostart</string>
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
  <string>$HOME/Library/Logs/MacSSTP/swiftbar-autostart.log</string>
  <key>StandardErrorPath</key>
  <string>$HOME/Library/Logs/MacSSTP/swiftbar-autostart.err.log</string>
</dict>
</plist>
EOF
  plutil -lint "$HOME/Library/LaunchAgents/com.macsstp.swiftbar-autostart.plist" >/dev/null
  launchctl unload "$HOME/Library/LaunchAgents/com.macsstp.swiftbar-autostart.plist" 2>/dev/null || true
  launchctl load "$HOME/Library/LaunchAgents/com.macsstp.swiftbar-autostart.plist"
  echo "Enabled SwiftBar autostart via LaunchAgent."
fi
