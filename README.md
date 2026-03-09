# VoicePress

VoicePress is a macOS menu bar dictation app for local push-to-talk speech-to-text.

## Current status

This repository is in milestone 5:

- native app shell scaffolded
- core app state modeled in a testable module
- microphone permission and manual audio recording scaffolded
- Apple Speech on-device transcription integration scaffolded
- clipboard-based text insertion scaffolded
- F6 global push-to-talk baseline restored
- repo prepared for local Whisper CLI backend
- official whisper.cpp binary and base.en model installed under `vendor/whisper.cpp`
- transcription interface and fixture eval harness scaffolded
- initial product and test docs added

## Planned v1

- menu bar app
- push-to-talk global hotkey
- local transcription
- clipboard-based insertion into the focused app

## Development

Build the package:

```bash
swift build
```

Run milestone checks:

```bash
swift run VoicePressCoreChecks
swift run VoicePressEval
```

Launch the app bundle for runtime testing:

```bash
./Scripts/run-app.sh
```

This installs the app to `/Applications/VoicePress.app` before launch so macOS permissions attach to a stable bundle path.
