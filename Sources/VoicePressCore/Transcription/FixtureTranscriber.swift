import Foundation

public struct FixtureTranscriber: Transcribing {
    public var backend: TranscriptionBackend {
        .whisperCLI(modelPath: "fixture")
    }

    public init() {}

    public func transcribe(audioFileAtPath path: String) async throws -> TranscriptionResult {
        guard FileManager.default.fileExists(atPath: path) else {
            throw TranscriptionError.missingAudioFile
        }

        let expectedTranscriptPath = transcriptPath(forAudioPath: path)
        guard FileManager.default.fileExists(atPath: expectedTranscriptPath) else {
            throw TranscriptionError.missingFixtureTranscript
        }

        let started = Date()
        let text = try String(contentsOfFile: expectedTranscriptPath, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let elapsed = Date().timeIntervalSince(started)

        return TranscriptionResult(text: text, engine: "fixture", elapsed: elapsed)
    }

    private func transcriptPath(forAudioPath path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let filename = url.deletingPathExtension().lastPathComponent + ".txt"
        return url.deletingLastPathComponent().appendingPathComponent(filename).path
    }
}
