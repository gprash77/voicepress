import AVFoundation
import Foundation
import VoicePressCore

@MainActor
final class AudioRecorder: NSObject, AudioRecordingManaging {
    private var recorder: AVAudioRecorder?
    private var startedAt: Date?
    private var outputURL: URL?

    func startRecording() async throws {
        guard recorder == nil else {
            throw AudioCaptureError.recorderAlreadyRunning
        }

        let outputURL = makeOutputURL()
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16_000,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsFloatKey: false,
        ]

        let recorder = try AVAudioRecorder(url: outputURL, settings: settings)
        recorder.prepareToRecord()

        guard recorder.record() else {
            throw AudioCaptureError.failedToStartRecording
        }

        self.recorder = recorder
        self.outputURL = outputURL
        startedAt = Date()
    }

    func stopRecording() async throws -> RecordingSummary {
        guard let recorder, let outputURL, let startedAt else {
            throw AudioCaptureError.recorderUnavailable
        }

        recorder.stop()
        let endedAt = Date()
        let duration = endedAt.timeIntervalSince(startedAt)

        self.recorder = nil
        self.outputURL = nil
        self.startedAt = nil

        return RecordingSummary(
            filePath: outputURL.path,
            startedAt: startedAt,
            endedAt: endedAt,
            duration: duration
        )
    }

    private func makeOutputURL() -> URL {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let filename = "recording-\(formatter.string(from: Date()).replacingOccurrences(of: ":", with: "-")).wav"
        return FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    }
}
