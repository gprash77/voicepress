import Foundation

public enum AudioCaptureError: LocalizedError, Equatable, Sendable {
    case microphonePermissionRequired
    case recorderAlreadyRunning
    case recorderUnavailable
    case failedToStartRecording
    case emptyRecording
    case recordingTooShort(minimumDuration: TimeInterval)

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
        case .emptyRecording:
            "No audio was captured. Hold F6 a bit longer before releasing."
        case .recordingTooShort(let minimumDuration):
            "Recording was too short. Hold F6 for at least \(String(format: "%.1f", minimumDuration)) seconds."
        }
    }
}
