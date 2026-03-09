import AVFoundation
import VoicePressCore

@MainActor
final class MicrophonePermissionManager: MicrophonePermissionManaging {
    func currentStatus() async -> MicrophonePermissionStatus {
        Self.map(status: AVCaptureDevice.authorizationStatus(for: .audio))
    }

    func requestAccess() async -> MicrophonePermissionStatus {
        let granted = await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }

        if granted {
            return .granted
        }

        return await currentStatus()
    }

    private static func map(status: AVAuthorizationStatus) -> MicrophonePermissionStatus {
        switch status {
        case .notDetermined:
            .undetermined
        case .restricted:
            .restricted
        case .denied:
            .denied
        case .authorized:
            .granted
        @unknown default:
            .denied
        }
    }
}
