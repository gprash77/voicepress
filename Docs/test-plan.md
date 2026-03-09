# Test Plan

## Automated checks

- state-machine self-check executable for the current toolchain
- self-checks for permission mapping and recording flow
- self-checks for insertion state transitions
- compile checks for global hotkey and accessibility wiring
- fixture-driven transcription evals
- smoke checks for package build and app startup

## Manual validation later

- TextEdit or Notes
- Safari or Chrome text field
- Cursor or VS Code
- one chat app

## Gate for milestone 1

- `swift build` succeeds
- `swift run VoicePressCoreChecks` succeeds
- app shell compiles with menu bar scene and settings scene
