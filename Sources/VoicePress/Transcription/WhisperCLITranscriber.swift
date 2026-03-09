import Foundation
import VoicePressCore

struct WhisperCLITranscriber: Transcribing {
    let executablePath: String
    let modelPath: String

    var backend: TranscriptionBackend {
        .whisperCLI(modelPath: modelPath)
    }

    init(
        executablePath: String = "/Applications/voicepress/vendor/whisper.cpp/build/bin/whisper-cli",
        modelPath: String = "/Applications/voicepress/vendor/whisper.cpp/models/ggml-base.en.bin"
    ) {
        self.executablePath = executablePath
        self.modelPath = modelPath
    }

    func transcribe(audioFileAtPath path: String) async throws -> TranscriptionResult {
        guard FileManager.default.fileExists(atPath: path) else {
            throw TranscriptionError.missingAudioFile
        }
        guard FileManager.default.fileExists(atPath: executablePath) else {
            throw TranscriptionError.engineUnavailable("whisper-cli was not found at \(executablePath).")
        }
        guard FileManager.default.fileExists(atPath: modelPath) else {
            throw TranscriptionError.engineUnavailable("Whisper model was not found at \(modelPath).")
        }

        let started = Date()
        let transcriptPath = path + ".txt"
        let executableURL = URL(fileURLWithPath: executablePath)
        let buildDirectory = executableURL.deletingLastPathComponent()
        let libraryPaths = [
            "/Applications/voicepress/vendor/whisper.cpp/build/src",
            "/Applications/voicepress/vendor/whisper.cpp/build/ggml/src",
            "/Applications/voicepress/vendor/whisper.cpp/build/ggml/src/ggml-blas",
            "/Applications/voicepress/vendor/whisper.cpp/build/ggml/src/ggml-metal",
        ].joined(separator: ":")

        if FileManager.default.fileExists(atPath: transcriptPath) {
            try? FileManager.default.removeItem(atPath: transcriptPath)
        }

        let process = Process()
        process.executableURL = executableURL
        process.currentDirectoryURL = buildDirectory
        process.environment = ProcessInfo.processInfo.environment.merging([
            "DYLD_LIBRARY_PATH": libraryPaths,
        ]) { _, new in new }
        process.arguments = [
            "--model", modelPath,
            "--file", path,
            "--no-prints",
            "--output-txt",
        ]

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let stdoutText = String(data: stdoutData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let stderrText = String(data: stderrData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if process.terminationStatus != 0 {
            let output = [stderrText, stdoutText].filter { !$0.isEmpty }.joined(separator: "\n")
            throw TranscriptionError.engineUnavailable(output.isEmpty ? "whisper-cli exited with status \(process.terminationStatus)." : output)
        }

        guard FileManager.default.fileExists(atPath: transcriptPath) else {
            let output = [stderrText, stdoutText].filter { !$0.isEmpty }.joined(separator: "\n")
            throw TranscriptionError.engineUnavailable(output.isEmpty ? "whisper-cli did not produce a transcript file." : output)
        }

        let text = try String(contentsOfFile: transcriptPath, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return TranscriptionResult(
            text: text,
            engine: "whisper-cli",
            elapsed: Date().timeIntervalSince(started)
        )
    }
}
