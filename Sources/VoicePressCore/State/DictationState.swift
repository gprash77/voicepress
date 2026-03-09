import Foundation

public struct RecordingSummary: Equatable, Sendable {
    public let filePath: String
    public let startedAt: Date
    public let endedAt: Date
    public let duration: TimeInterval

    public init(filePath: String, startedAt: Date, endedAt: Date, duration: TimeInterval) {
        self.filePath = filePath
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.duration = duration
    }
}

public enum DictationState: Equatable, Sendable {
    case idle
    case recording
    case recorded(RecordingSummary)
    case transcribing
    case inserting
    case error(String)

    public var displayLabel: String {
        switch self {
        case .idle:
            "Idle"
        case .recording:
            "Recording"
        case .recorded:
            "Recorded"
        case .transcribing:
            "Transcribing"
        case .inserting:
            "Inserting"
        case .error(let message):
            "Error: \(message)"
        }
    }
}
