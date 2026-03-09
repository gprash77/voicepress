import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        Form {
            Text("Current State: \(viewModel.state.displayLabel)")
            Text("Microphone: \(viewModel.microphonePermission.displayLabel)")
            Text("Speech: \(speechStatusLabel)")
            Text("Accessibility: \(accessibilityStatusLabel)")
            Text("Hotkey: F6")
            Text("Transcription: \(viewModel.transcriptionBackend.displayLabel)")
            if let lastRecording = viewModel.lastRecording {
                LabeledContent("Last Duration", value: String(format: "%.1fs", lastRecording.duration))
                Text(lastRecording.filePath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let transcript = viewModel.lastTranscript {
                Text(transcript.text)
                    .font(.caption)
                LabeledContent("Last Engine", value: transcript.engine)
            }
        }
        .padding(20)
        .frame(width: 360)
    }

    private var speechStatusLabel: String {
        viewModel.transcriptionBackend.requiresSpeechRecognitionPermission
            ? viewModel.speechPermission.displayLabel
            : "Not Required"
    }

    private var accessibilityStatusLabel: String {
        let label = viewModel.accessibilityPermission.displayLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        return label.isEmpty ? "Unknown" : label
    }
}
