import Speech
import VoicePressCore

@MainActor
final class SpeechRecognitionPermissionManager: SpeechRecognitionPermissionManaging {
    func currentStatus() async -> SpeechRecognitionPermissionStatus {
        Self.map(status: SFSpeechRecognizer.authorizationStatus())
    }

    func requestAccess() async -> SpeechRecognitionPermissionStatus {
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                Task { @MainActor in
                    continuation.resume(returning: status)
                }
            }
        }

        return Self.map(status: status)
    }

    private static func map(status: SFSpeechRecognizerAuthorizationStatus) -> SpeechRecognitionPermissionStatus {
        switch status {
        case .notDetermined:
            .undetermined
        case .denied:
            .denied
        case .restricted:
            .restricted
        case .authorized:
            .granted
        @unknown default:
            .denied
        }
    }
}
