import Foundation

public struct TranscriptExpectation: Codable, Equatable, Sendable {
    public let audioFile: String
    public let expectedText: String

    public init(audioFile: String, expectedText: String) {
        self.audioFile = audioFile
        self.expectedText = expectedText
    }
}
