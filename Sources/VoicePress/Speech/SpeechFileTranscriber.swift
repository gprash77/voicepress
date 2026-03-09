import Foundation
import Speech
import VoicePressCore

struct SpeechFileTranscriber: Transcribing {
    let localeIdentifier: String

    var backend: TranscriptionBackend {
        .appleSpeechOnDevice(localeIdentifier: localeIdentifier)
    }

    init(localeIdentifier: String = "en-US") {
        self.localeIdentifier = localeIdentifier
    }

    func transcribe(audioFileAtPath path: String) async throws -> TranscriptionResult {
        guard FileManager.default.fileExists(atPath: path) else {
            throw TranscriptionError.missingAudioFile
        }

        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)) else {
            throw TranscriptionError.engineUnavailable("Speech recognizer could not be created for locale \(localeIdentifier).")
        }

        guard recognizer.supportsOnDeviceRecognition else {
            throw TranscriptionError.engineUnavailable("On-device speech recognition is not available for locale \(localeIdentifier).")
        }

        let request = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: path))
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false
        request.taskHint = .dictation

        let started = Date()

        return try await withCheckedThrowingContinuation { continuation in
            var task: SFSpeechRecognitionTask?
            task = recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    task?.cancel()
                    continuation.resume(throwing: error)
                    return
                }

                guard let result else {
                    return
                }

                if result.isFinal {
                    task?.cancel()
                    continuation.resume(
                        returning: TranscriptionResult(
                            text: result.bestTranscription.formattedString,
                            engine: "apple-speech-on-device",
                            elapsed: Date().timeIntervalSince(started)
                        )
                    )
                }
            }
        }
    }
}
