import SwiftUI
import VoicePressCore

struct ContentView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VoicePress")
                .font(.headline)

            Text(viewModel.state.displayLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            statusRow("Microphone", viewModel.microphonePermission.displayLabel)
            statusRow("Speech", speechStatusLabel)
            statusRow("Accessibility", accessibilityStatusLabel)
            statusRow("Backend", viewModel.transcriptionBackend.displayLabel)
            statusRow("Last Event", lastEventLabel)

            if let lastRecording = viewModel.lastRecording {
                LabeledContent("Last Clip", value: String(format: "%.1fs", lastRecording.duration))
                    .font(.footnote)
                Text(lastRecording.filePath)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            if let transcript = viewModel.lastTranscript {
                Divider()
                Text(transcript.text)
                    .font(.footnote)
                Text("\(transcript.engine) · \(String(format: "%.2fs", transcript.elapsed))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let lastInsertedText = viewModel.lastInsertedText {
                Divider()
                Text("Inserted")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(lastInsertedText)
                    .font(.footnote)
                    .lineLimit(3)
            }

            Divider()

            Text("Hold F6 to dictate")
                .font(.footnote)

            Button(primaryButtonTitle) {
                Task {
                    await viewModel.handlePrimaryAction()
                }
            }
            .keyboardShortcut(.space, modifiers: [])

            if case .recording = viewModel.state {
                Button("Force Stop Recording") {
                    Task {
                        await viewModel.handlePrimaryAction()
                    }
                }
            }

            if viewModel.microphonePermission != .granted {
                Button("Request Microphone Access") {
                    Task {
                        await viewModel.requestMicrophoneAccess()
                    }
                }
            }

            if viewModel.transcriptionBackend.requiresSpeechRecognitionPermission, viewModel.speechPermission != .granted {
                Button("Request Speech Access") {
                    Task {
                        await viewModel.requestSpeechAccess()
                    }
                }
            }

            if viewModel.accessibilityPermission != .granted {
                Button("Request Accessibility Access") {
                    Task {
                        await viewModel.requestAccessibilityAccess()
                    }
                }
            }

            Button("Refresh Accessibility Status") {
                Task {
                    await viewModel.refreshAccessibilityStatusAndMonitoring()
                }
            }

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(16)
        .frame(width: 240)
    }

    private var primaryButtonTitle: String {
        switch viewModel.state {
        case .recording:
            "Stop Recording"
        default:
            "Start Recording"
        }
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

    private var lastEventLabel: String {
        let label = viewModel.lastEventDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return label.isEmpty ? "None" : label
    }

    @ViewBuilder
    private func statusRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text("\(title):")
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.footnote)
    }
}
