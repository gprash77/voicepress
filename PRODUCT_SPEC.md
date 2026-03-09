# VoicePress Product Spec

## Goal

Build a macOS menu bar dictation utility that records while a global hotkey is held, transcribes locally, and pastes text into the currently focused app.

## V1 scope

In scope:

- macOS only
- menu bar app
- push-to-talk interaction
- local speech-to-text
- clipboard-based paste into focused apps
- support target: browser text fields, TextEdit or Notes, Cursor or VS Code, one chat app

Out of scope:

- cross-platform support
- cloud transcription
- wake word activation
- universal compatibility across all apps

## Milestones

1. App shell and state model
2. Audio capture
3. Local transcription and eval harness
4. Clipboard insertion and transcript handoff
5. Global hotkey and accessibility permission
6. Permissions UX
7. Compatibility validation

## Validation philosophy

Each milestone must include:

- code changes
- tests, self-checks, or evals for the layer being added
- a short verification pass before manual user testing
