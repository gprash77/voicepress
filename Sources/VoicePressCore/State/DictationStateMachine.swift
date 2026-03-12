import Foundation

public enum DictationEvent: Equatable, Sendable {
    case pressHotkey
    case releaseHotkey
    case finishRecording(RecordingSummary)
    case transcriptionStarted
    case insertionStarted
    case reset
    case fail(String)
}

public struct DictationStateMachine: Sendable {
    public private(set) var state: DictationState = .idle

    public init() {}

    public mutating func handle(_ event: DictationEvent) {
        switch (state, event) {
        case (.idle, .pressHotkey), (.recorded, .pressHotkey), (.error, .pressHotkey):
            state = .recording
        case (.recording, .releaseHotkey):
            break
        case (.recording, .finishRecording(let summary)):
            state = .recorded(summary)
        case (.recorded, .transcriptionStarted):
            state = .transcribing
        case (.transcribing, .insertionStarted):
            state = .inserting
        case (.transcribing, .transcriptionStarted):
            state = .transcribing
        case (.recorded, .reset), (.inserting, .reset), (.error, .reset):
            state = .idle
        case (_, .fail(let message)):
            state = .error(message)
        default:
            break
        }
    }
}
