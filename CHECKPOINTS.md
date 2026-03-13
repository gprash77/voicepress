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

## 2026-03-11 - Whisper path resolution stabilized

- Goal: Resume from the baseline checkpoint and remove environment-specific Whisper path failures.
- Code state: Whisper CLI/model/runtime library paths now resolve from discovered repo roots (with `VOICEPRESS_ROOT` override) instead of hardcoded `/Applications/voicepress`; eval runner paths also resolve dynamically.
- Verified behavior:
  - `swift build` passed
  - `swift run VoicePressCoreChecks` passed
  - `swift run VoicePressEval` passed
- Remaining risk:
  - repeated `F6` runs are still unreliable and need focused runtime validation
- Commit hash: pending

## 2026-03-11 - Event tap auto-recovery added

- Goal: Improve `F6` hotkey reliability without changing other runtime variables.
- Code state: global hotkey monitor now re-enables its Quartz event tap when macOS disables it for timeout or user-input reasons.
- Verified behavior:
  - `swift build` passed
  - `swift run VoicePressCoreChecks` passed
  - `swift run VoicePressEval` passed
- Remaining risk:
  - installed-app runtime still needs manual verification that repeated `F6` press/release cycles keep working without a relaunch
- Commit hash: pending

## 2026-03-11 - Installed-app dictation baseline stabilized

- Goal: Finish the recovery phase and confirm a usable end-to-end installed-app dictation loop.
- Code state:
  - Whisper paths resolve from the repo instead of hardcoded `/Applications/voicepress`
  - global hotkey monitoring recovers when the event tap is disabled
  - state machine restarts cleanly after transcription errors
  - duplicate stop handling is ignored unless the app is actively recording
  - empty or too-short taps fail early before Whisper runs
  - Whisper CLI now uses short-English dictation-oriented flags and an initial prompt for the app name
- Verified behavior:
  - `swift build` passed
  - `swift run VoicePressCoreChecks` passed
  - `swift run VoicePressEval` passed
  - repeated `F6` press/release cycles no longer get stuck in `A recording session is already active`
  - quick taps show a clear `No audio was captured` message
  - a normal hold reaches `Recording -> Transcribing -> Inserting -> Idle`
  - real-user phrase test for `testing voice press` was accurate three times in a row
- Remaining risk:
  - transcription quality still needs broader phrase-set validation
  - insertion should still be checked across a small app matrix
- Commit hash: pending

## 2026-03-13 - Small model app-matrix baseline improved

- Goal: Improve recognition quality across common target apps without changing the installed-app insertion path.
- Code state:
  - Whisper model selection now supports `VOICEPRESS_MODEL_PATH`
  - app now prefers `ggml-small.en.bin` when it exists locally, falling back to `ggml-base.en.bin`
  - dictation prompt expanded with common desktop app names to reduce proper-noun drift
- Verified behavior:
  - `swift build` passed
  - `swift run VoicePressCoreChecks` passed
  - `swift run VoicePressEval` passed
  - installed `/Applications/VoicePress.app` was relaunched against the updated model selection
  - manual app-matrix retest improved materially with `small.en`
  - `SMS` recognized correctly in a chat window
  - website text field recognized `testing voice press in a website`
- Remaining risk:
  - app-specific proper nouns still drift, including `Codex -> codec` and `TextEdit/TextPad -> text pack`
  - repeated phrase-set validation is still needed before treating transcription quality as stable
- Commit hash: pending
