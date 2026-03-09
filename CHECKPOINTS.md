# Checkpoints

## Checkpoint format

- Date
- Goal
- Code state
- Verified behavior
- Remaining risk
- Commit hash

## 2026-03-09 - Initial macOS app scaffold

- Goal: Build a native menu bar shell with a testable state model.
- Code state: Swift package app shell, core state machine, self-check executable.
- Verified behavior:
  - `swift build` passed
  - `swift run VoicePressCoreChecks` passed
- Remaining risk:
  - No real microphone, transcription, or insertion path validated yet.
- Commit hash: not yet committed

## 2026-03-09 - Audio, Apple Speech, and insertion integration

- Goal: Reach an end-to-end dictation flow on macOS.
- Code state: microphone capture, Apple Speech on-device path, clipboard insertion, global hotkey experiments.
- Verified behavior:
  - End-to-end dictation worked at least once with the earlier `F6` path.
- Remaining risk:
  - Accessibility permission and hotkey handling became unstable after multiple changes.
  - No stable checkpoint was committed before later experiments.
- Commit hash: not yet committed

## 2026-03-09 - Whisper integration in progress

- Goal: Upgrade local transcription quality.
- Code state: `whisper.cpp` installed under `vendor/whisper.cpp`, app default backend changed to Whisper.
- Verified behavior:
  - `whisper-cli` built successfully
  - base English model downloaded successfully
  - app compiles with Whisper backend
- Remaining risk:
  - Runtime baseline is not stable enough yet to evaluate Whisper quality cleanly.
- Commit hash: not yet committed

## Active checkpoint target

- Goal: Restore a stable installed-app baseline with explicit status UI and the simpler `F6` hotkey path.
- Exit criteria:
  - `/Applications/VoicePress.app` is the only running instance
  - accessibility status is visible and trustworthy
  - `F6` path can be tested again without changing any other variable

## 2026-03-09 - Installed-app baseline recovered

- Goal: Recover a trustworthy runtime baseline before further hotkey/transcription changes.
- Code state: installed app path stabilized at `/Applications/VoicePress.app`, explicit status UI added, `F6` baseline restored, Whisper backend still active.
- Verified behavior:
  - correct/latest app instance confirmed
  - `Accessibility: Granted` confirmed after clean remove/re-add flow
  - one end-to-end dictation run previously worked
  - latest hotkey layer moved to Quartz event tap
- Remaining risk:
  - repeated `F6` runs are still unreliable
  - current Whisper path still errors at runtime in app context and needs further debugging
- Commit hash: pending
