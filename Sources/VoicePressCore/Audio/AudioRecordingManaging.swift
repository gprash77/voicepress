import Foundation

@MainActor
public protocol AudioRecordingManaging: AnyObject {
    func startRecording() async throws
    func stopRecording() async throws -> RecordingSummary
}
