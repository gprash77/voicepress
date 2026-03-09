import SwiftUI
import VoicePressCore

@main
struct VoicePressApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        MenuBarExtra("VoicePress", systemImage: "waveform.circle.fill") {
            ContentView(viewModel: viewModel)
        }

        Settings {
            SettingsView(viewModel: viewModel)
        }
    }
}
