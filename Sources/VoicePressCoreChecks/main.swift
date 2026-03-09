import Foundation
import VoicePressCore

struct CheckFailure: Error, CustomStringConvertible {
    let description: String
}

@inline(__always)
func expect(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() {
        throw CheckFailure(description: message)
    }
}

func runChecks() throws {
    do {
        var machine = DictationStateMachine()
        machine.handle(.pressHotkey)
        try expect(machine.state == .recording, "pressHotkey should move idle -> recording")
    }

    do {
        var machine = DictationStateMachine()
        machine.handle(.pressHotkey)
        machine.handle(.releaseHotkey)
        try expect(machine.state == .recording, "releaseHotkey should not advance before recording is finalized")
    }

    do {
        var machine = DictationStateMachine()
        machine.handle(.pressHotkey)
        let summary = RecordingSummary(
            filePath: "/tmp/sample.m4a",
            startedAt: Date(timeIntervalSince1970: 10),
            endedAt: Date(timeIntervalSince1970: 13),
            duration: 3
        )
        machine.handle(.finishRecording(summary))
        try expect(machine.state == .recorded(summary), "finishRecording should move recording -> recorded")
    }

    do {
        var machine = DictationStateMachine()
        machine.handle(.pressHotkey)
        let summary = RecordingSummary(
            filePath: "/tmp/sample.m4a",
            startedAt: Date(timeIntervalSince1970: 10),
            endedAt: Date(timeIntervalSince1970: 13),
            duration: 3
        )
        machine.handle(.finishRecording(summary))
        machine.handle(.transcriptionStarted)
        machine.handle(.insertionStarted)
        try expect(machine.state == .inserting, "insertionStarted should move transcribing -> inserting")
    }

    do {
        var machine = DictationStateMachine()
        machine.handle(.pressHotkey)
        let summary = RecordingSummary(
            filePath: "/tmp/sample.m4a",
            startedAt: Date(timeIntervalSince1970: 10),
            endedAt: Date(timeIntervalSince1970: 13),
            duration: 3
        )
        machine.handle(.finishRecording(summary))
        machine.handle(.transcriptionStarted)
        machine.handle(.insertionStarted)
        machine.handle(.reset)
        try expect(machine.state == .idle, "reset should move inserting -> idle")
    }

    do {
        var machine = DictationStateMachine()
        machine.handle(.pressHotkey)
        let summary = RecordingSummary(
            filePath: "/tmp/sample.m4a",
            startedAt: Date(timeIntervalSince1970: 10),
            endedAt: Date(timeIntervalSince1970: 13),
            duration: 3
        )
        machine.handle(.finishRecording(summary))
        machine.handle(.reset)
        try expect(machine.state == .idle, "reset should move recorded -> idle")
    }

    do {
        var machine = DictationStateMachine()
        machine.handle(.fail("microphone unavailable"))
        try expect(machine.state == .error("microphone unavailable"), "fail should move any state -> error")
    }

    do {
        try expect(MicrophonePermissionStatus.granted.canRecord, "granted permission should allow recording")
        try expect(!MicrophonePermissionStatus.denied.canRecord, "denied permission should block recording")
        try expect(SpeechRecognitionPermissionStatus.granted.canTranscribe, "granted speech permission should allow transcription")
        try expect(!SpeechRecognitionPermissionStatus.denied.canTranscribe, "denied speech permission should block transcription")
        try expect(AccessibilityPermissionStatus.granted.canMonitorGlobalInput, "granted accessibility permission should allow global hotkey monitoring")
        try expect(!AccessibilityPermissionStatus.denied.canMonitorGlobalInput, "denied accessibility permission should block global hotkey monitoring")
        try expect(TextInsertionError.emptyText.errorDescription == "There is no text to insert.", "text insertion errors should expose stable descriptions")
    }
}

do {
    try runChecks()
    print("VoicePressCoreChecks passed")
} catch {
    fputs("VoicePressCoreChecks failed: \(error)\n", stderr)
    exit(1)
}
