import Foundation
import VoicePressCore

@main
struct VoicePressCLI {
    static func main() async {
        guard CommandLine.arguments.count >= 2 else {
            fputs("Usage: VoicePressCLI <audio-file>\n", stderr)
            exit(2)
        }

        let path = CommandLine.arguments[1]
        let transcriber = FixtureTranscriber()

        do {
            let result = try await transcriber.transcribe(audioFileAtPath: path)
            print(result.text)
        } catch {
            fputs("VoicePressCLI failed: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
}
