import Foundation
import VoicePressCore

struct WhisperCLITranscriber: Transcribing {
    let executablePath: String
    let modelPath: String
    private let libraryPaths: String

    var backend: TranscriptionBackend {
        .whisperCLI(modelPath: modelPath)
    }

    init(
        executablePath: String? = nil,
        modelPath: String? = nil
    ) {
        let resolvedExecutablePath = executablePath ?? Self.resolveDefaultExecutablePath()
        self.executablePath = resolvedExecutablePath

        let resolvedBuildRoot = URL(fileURLWithPath: resolvedExecutablePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path

        self.modelPath = modelPath ?? Self.resolveDefaultModelPath()
        self.libraryPaths = [
            "\(resolvedBuildRoot)/src",
            "\(resolvedBuildRoot)/ggml/src",
            "\(resolvedBuildRoot)/ggml/src/ggml-blas",
            "\(resolvedBuildRoot)/ggml/src/ggml-metal",
        ].joined(separator: ":")
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
            "--language", "en",
            "--no-timestamps",
            "--max-context", "0",
            "--split-on-word",
            "--prompt", "VoicePress is the app name. This is short English dictation.",
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

    private static func resolveDefaultExecutablePath() -> String {
        for root in candidateRoots() {
            let candidate = "\(root)/vendor/whisper.cpp/build/bin/whisper-cli"
            if FileManager.default.fileExists(atPath: candidate) {
                return candidate
            }
        }
        return "\(candidateRoots().first ?? FileManager.default.currentDirectoryPath)/vendor/whisper.cpp/build/bin/whisper-cli"
    }

    private static func resolveDefaultModelPath() -> String {
        for root in candidateRoots() {
            let candidate = "\(root)/vendor/whisper.cpp/models/ggml-base.en.bin"
            if FileManager.default.fileExists(atPath: candidate) {
                return candidate
            }
        }
        return "\(candidateRoots().first ?? FileManager.default.currentDirectoryPath)/vendor/whisper.cpp/models/ggml-base.en.bin"
    }

    private static func candidateRoots() -> [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        let sourcePath = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path

        return [
            ProcessInfo.processInfo.environment["VOICEPRESS_ROOT"],
            FileManager.default.currentDirectoryPath,
            sourcePath,
            "\(home)/projects/voicepress",
            "\(home)/voicepress",
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    }
}
