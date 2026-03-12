# VoicePress Plan

## Current objective

Hold a stable installed-app baseline for macOS push-to-talk dictation and improve transcription quality without regressing the recovered `F6` workflow.

## Immediate steps

1. Keep `/Applications/VoicePress.app` as the only runtime test target.
2. Preserve the recovered `F6` press/release path and short-recording guard.
3. Tune Whisper quality with repeatable short-phrase checks.
4. Expand manual validation across a small app matrix once quality is stable.

## Validation rule

Do not change more than one runtime variable between manual tests.

## Current baseline

1. Accessibility status is explicit and refreshable.
2. `F6` hotkey monitoring auto-recovers if the event tap is disabled.
3. Empty or too-short taps fail early with a clear message.
4. Repeated real-world `testing voice press` trials now complete accurately in the installed app.

## Next after baseline

1. Validate Whisper quality against a small fixed phrase set.
2. Validate insertion behavior in a small app matrix.
3. Decide whether to keep `base.en` or move to a larger local model.
