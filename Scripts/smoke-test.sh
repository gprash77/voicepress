#!/bin/sh

set -eu

swift build
swift run VoicePressCoreChecks
swift run VoicePressEval
