import Foundation

public struct TranscriptionEval: Equatable, Sendable {
    public let audioFile: String
    public let expectedText: String
    public let actualText: String
    public let engine: String
    public let elapsed: TimeInterval

    public var passedExactMatch: Bool {
        actualText.trimmingCharacters(in: .whitespacesAndNewlines) == expectedText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public struct TranscriptionEvalRunner: Sendable {
    private let transcriber: any Transcribing

    public init(transcriber: any Transcribing) {
        self.transcriber = transcriber
    }

    public func run(expectations: [TranscriptExpectation], fixtureDirectory: String) async throws -> [TranscriptionEval] {
        var results: [TranscriptionEval] = []

        for expectation in expectations {
            let path = URL(fileURLWithPath: fixtureDirectory)
                .appendingPathComponent(expectation.audioFile)
                .path
            let result = try await transcriber.transcribe(audioFileAtPath: path)
            results.append(
                TranscriptionEval(
                    audioFile: expectation.audioFile,
                    expectedText: expectation.expectedText,
                    actualText: result.text,
                    engine: result.engine,
                    elapsed: result.elapsed
                )
            )
        }

        return results
    }
}
