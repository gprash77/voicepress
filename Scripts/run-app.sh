#!/bin/sh

set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
"$ROOT_DIR/Scripts/install-app.sh" >/dev/null
open /Applications/VoicePress.app
