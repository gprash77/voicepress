import Foundation

public protocol Transcribing: Sendable {
    var backend: TranscriptionBackend { get }
    func transcribe(audioFileAtPath path: String) async throws -> TranscriptionResult
}
