# VoicePress Plan

## Current objective

Hold a stable installed-app baseline for macOS push-to-talk dictation on `small.en` without regressing the recovered `F6` workflow.

## Immediate steps

1. Keep `/Applications/VoicePress.app` as the only runtime test target.
2. Preserve the recovered `F6` press/release path and short-recording guard.
3. Validate `small.en` against a fixed short-phrase set focused on proper nouns.
4. Expand manual validation across a small app matrix once phrase accuracy is stable.

## Validation rule

Do not change more than one runtime variable between manual tests.

## Current baseline

1. Accessibility status is explicit and refreshable.
2. `F6` hotkey monitoring auto-recovers if the event tap is disabled.
3. Empty or too-short taps fail early with a clear message.
4. `small.en` materially improves cross-app transcription compared with `base.en`.
5. Insertion is working in TextEdit, browser text fields, Codex, and SMS chat targets.

## Next after baseline

1. Run a fixed phrase-set validation for `Codex`, `TextEdit`, `Claude Code`, `Messages`, `Safari`, and `Chrome`.
2. Evaluate a small post-correction dictionary for known app names and product terms such as `Codex`, `Claude Code`, `Messages`, and `TextEdit`.
3. Decide whether prompt tuning plus targeted correction is enough for app names or whether another model step is still needed.
4. Once transcription quality is stable, turn the current manual app-matrix into a repeatable checklist.
