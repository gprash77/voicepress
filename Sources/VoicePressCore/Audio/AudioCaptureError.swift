import Foundation

public enum AudioCaptureError: LocalizedError, Equatable, Sendable {
    case microphonePermissionRequired
    case recorderAlreadyRunning
    case recorderUnavailable
    case failedToStartRecording

    public var errorDescription: String? {
        switch self {
        case .microphonePermissionRequired:
            "Microphone permission is required."
        case .recorderAlreadyRunning:
            "A recording session is already active."
        case .recorderUnavailable:
            "Audio recorder is unavailable."
        case .failedToStartRecording:
            "Audio recording could not be started."
        }
    }
}
