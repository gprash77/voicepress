#!/bin/sh

set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
APP_BUNDLE="$ROOT_DIR/.build/arm64-apple-macosx/debug/VoicePress.app"
INSTALL_PATH="/Applications/VoicePress.app"

"$ROOT_DIR/Scripts/make-app-bundle.sh" >/dev/null
rm -rf "$INSTALL_PATH"
cp -R "$APP_BUNDLE" "$INSTALL_PATH"

echo "$INSTALL_PATH"
