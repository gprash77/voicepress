# VoicePress Plan

## Current objective

Recover a stable baseline for macOS push-to-talk dictation by reducing moving parts and validating one system integration at a time.

## Immediate steps

1. Roll back the hotkey path to the simpler `F6` implementation.
2. Fix the blank status display so permission state is explicit.
3. Rebuild and install only `/Applications/VoicePress.app`.
4. Validate the baseline before changing transcription or compatibility behavior.

## Validation rule

Do not change more than one runtime variable between manual tests.

## Next after baseline

1. Validate hotkey reliability.
2. Validate Whisper quality against the same short phrases.
3. Validate a small app matrix.
