import Foundation

@MainActor
public protocol SpeechRecognitionPermissionManaging: AnyObject {
    func currentStatus() async -> SpeechRecognitionPermissionStatus
    func requestAccess() async -> SpeechRecognitionPermissionStatus
}
