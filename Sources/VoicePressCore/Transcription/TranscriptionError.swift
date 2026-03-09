import Foundation

public enum TranscriptionError: LocalizedError, Equatable, Sendable {
    case missingAudioFile
    case missingFixtureTranscript
    case engineUnavailable(String)

    public var errorDescription: String? {
        switch self {
        case .missingAudioFile:
            "Audio file is missing."
        case .missingFixtureTranscript:
            "Expected fixture transcript is missing."
        case .engineUnavailable(let message):
            "Transcription engine unavailable: \(message)"
        }
    }
}
