#!/bin/bash
set -e

CERT_NAME="ShortcutCounter Dev"
APP_NAME="ShortcutCounter.app"
APP_SRC="$APP_NAME"
APP_DST="/Applications/$APP_NAME"
BINARY_SRC=".build/release/ShortcutCounter"
BINARY_DST="$APP_SRC/Contents/MacOS/ShortcutCounter"

# Stop bestaande instanties
pkill -x ShortcutCounter 2>/dev/null || true
sleep 0.5

# Bouw
swift build --configuration release

# Kopieer nieuwe binary naar lokale .app bundle
cp "$BINARY_SRC" "$BINARY_DST"

# Verwijder oude versie en kopieer nieuwe naar /Applications
rm -rf "$APP_DST"
cp -R "$APP_SRC" "$APP_DST"

# Sign de .app bundle NA het kopiëren naar /Applications
codesign --deep --force --sign "$CERT_NAME" "$APP_DST"

# Start vanuit /Applications
open "$APP_DST"
echo "ShortcutCounter gestart vanuit /Applications"
