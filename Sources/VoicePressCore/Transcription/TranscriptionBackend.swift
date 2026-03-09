import Foundation

public enum TranscriptionBackend: Equatable, Sendable {
    case appleSpeechOnDevice(localeIdentifier: String)
    case whisperCLI(modelPath: String)

    public var displayLabel: String {
        switch self {
        case .appleSpeechOnDevice:
            "Apple Speech on-device"
        case .whisperCLI:
            "Whisper CLI"
        }
    }

    public var requiresSpeechRecognitionPermission: Bool {
        switch self {
        case .appleSpeechOnDevice:
            true
        case .whisperCLI:
            false
        }
    }
}
