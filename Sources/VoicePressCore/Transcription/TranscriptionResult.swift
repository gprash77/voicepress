import Foundation

public struct TranscriptionResult: Equatable, Sendable {
    public let text: String
    public let engine: String
    public let elapsed: TimeInterval

    public init(text: String, engine: String, elapsed: TimeInterval) {
        self.text = text
        self.engine = engine
        self.elapsed = elapsed
    }
}
