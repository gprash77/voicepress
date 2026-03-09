import Foundation
import VoicePressCore

struct EvalFile: Codable {
    let fixtures: [TranscriptExpectation]
}

@main
struct VoicePressEval {
    static func main() async {
        let fixtureDirectory = "/Applications/voicepress/Tests/Evals/Fixtures"
        let expectationFile = "/Applications/voicepress/Tests/Evals/expectations.json"

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: expectationFile))
            let expectations = try JSONDecoder().decode(EvalFile.self, from: data).fixtures
            let runner = TranscriptionEvalRunner(transcriber: FixtureTranscriber())
            let results = try await runner.run(expectations: expectations, fixtureDirectory: fixtureDirectory)

            for result in results {
                let status = result.passedExactMatch ? "PASS" : "FAIL"
                print("\(status)\t\(result.audioFile)\tengine=\(result.engine)\telapsed=\(String(format: "%.4f", result.elapsed))s")
            }

            if results.allSatisfy(\.passedExactMatch) {
                print("VoicePressEval passed")
            } else {
                fputs("VoicePressEval failed: one or more fixtures did not match\n", stderr)
                exit(1)
            }
        } catch {
            fputs("VoicePressEval failed: \(error.localizedDescription)\n", stderr)
            exit(1)
        }
    }
}
