#!/bin/sh

set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build/arm64-apple-macosx/debug"
APP_DIR="$BUILD_DIR/VoicePress.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

mkdir -p "$MACOS_DIR"
cp "$ROOT_DIR/Sources/VoicePress/Resources/Info.plist" "$CONTENTS_DIR/Info.plist"
cp "$BUILD_DIR/VoicePress" "$MACOS_DIR/VoicePress"
chmod +x "$MACOS_DIR/VoicePress"

echo "$APP_DIR"
