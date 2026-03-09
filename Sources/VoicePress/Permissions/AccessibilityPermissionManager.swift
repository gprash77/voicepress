import ApplicationServices
import VoicePressCore

@MainActor
final class AccessibilityPermissionManager: AccessibilityPermissionManaging {
    func currentStatus() async -> AccessibilityPermissionStatus {
        AXIsProcessTrusted() ? .granted : .denied
    }

    func requestAccess() async -> AccessibilityPermissionStatus {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        return await currentStatus()
    }
}
