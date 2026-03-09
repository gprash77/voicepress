import Foundation

@MainActor
public protocol MicrophonePermissionManaging: AnyObject {
    func currentStatus() async -> MicrophonePermissionStatus
    func requestAccess() async -> MicrophonePermissionStatus
}
