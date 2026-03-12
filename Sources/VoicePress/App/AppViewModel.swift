import Foundation
import OSLog
import VoicePressCore

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var state: DictationState = .idle
    @Published private(set) var microphonePermission: MicrophonePermissionStatus = .undetermined
    @Published private(set) var speechPermission: SpeechRecognitionPermissionStatus = .undetermined
    @Published private(set) var accessibilityPermission: AccessibilityPermissionStatus = .denied
    @Published private(set) var lastRecording: RecordingSummary?
    @Published private(set) var lastTranscript: TranscriptionResult?
    @Published private(set) var lastInsertedText: String?
    @Published private(set) var transcriptionBackend: TranscriptionBackend
    @Published private(set) var lastEventDescription: String = "Idle"

    private let permissionManager: any MicrophonePermissionManaging
    private let speechPermissionManager: any SpeechRecognitionPermissionManaging
    private let accessibilityPermissionManager: any AccessibilityPermissionManaging
    private let audioRecorder: any AudioRecordingManaging
    private let transcriber: any Transcribing
    private let textInserter: any TextInserting
    private let hotkeyMonitor: any GlobalHotkeyMonitoring
    private var machine = DictationStateMachine()
    private var isHotkeyActive = false
    private var hasBootstrapped = false
    private let logger = Logger(subsystem: "com.codex.voicepress", category: "app")
    private var recordingSafetyTask: Task<Void, Never>?

    init(
        permissionManager: any MicrophonePermissionManaging = MicrophonePermissionManager(),
        speechPermissionManager: any SpeechRecognitionPermissionManaging = SpeechRecognitionPermissionManager(),
        accessibilityPermissionManager: any AccessibilityPermissionManaging = AccessibilityPermissionManager(),
        audioRecorder: any AudioRecordingManaging = AudioRecorder(),
        transcriber: any Transcribing = WhisperCLITranscriber(),
        textInserter: any TextInserting = ClipboardTextInserter(),
        hotkeyMonitor: any GlobalHotkeyMonitoring = GlobalHotkeyMonitor()
    ) {
        self.permissionManager = permissionManager
        self.speechPermissionManager = speechPermissionManager
        self.accessibilityPermissionManager = accessibilityPermissionManager
        self.audioRecorder = audioRecorder
        self.transcriber = transcriber
        self.textInserter = textInserter
        self.hotkeyMonitor = hotkeyMonitor
        self.transcriptionBackend = transcriber.backend

        Task { @MainActor in
            await bootstrap()
        }
    }

    func setState(_ newState: DictationState) {
        state = newState
    }

    func refreshMicrophonePermission() async {
        microphonePermission = await permissionManager.currentStatus()
    }

    func refreshSpeechPermission() async {
        speechPermission = await speechPermissionManager.currentStatus()
    }

    func refreshAccessibilityPermission() async {
        accessibilityPermission = await accessibilityPermissionManager.currentStatus()
    }

    func requestMicrophoneAccess() async {
        microphonePermission = await permissionManager.requestAccess()
        note("Microphone permission: \(microphonePermission.displayLabel)")
    }

    func requestSpeechAccess() async {
        speechPermission = await speechPermissionManager.requestAccess()
        note("Speech permission: \(speechPermission.displayLabel)")
    }

    func requestAccessibilityAccess() async {
        accessibilityPermission = await accessibilityPermissionManager.requestAccess()
        note("Accessibility prompt opened")
    }

    func bootstrap() async {
        guard !hasBootstrapped else {
            return
        }

        hasBootstrapped = true
        await refreshMicrophonePermission()
        await refreshSpeechPermission()
        await refreshAccessibilityPermission()
        note("Bootstrapped app state")
        startHotkeyMonitoring()
    }

    func refreshAccessibilityStatusAndMonitoring() async {
        await refreshAccessibilityPermission()
        note("Accessibility permission: \(accessibilityPermission.displayLabel)")
        if accessibilityPermission.canMonitorGlobalInput {
            startHotkeyMonitoring()
        } else {
            stopHotkeyMonitoring()
        }
    }

    func startHotkeyMonitoring() {
        guard accessibilityPermission.canMonitorGlobalInput else {
            return
        }

        hotkeyMonitor.start { [weak self] event in
            guard let self else {
                return
            }

            Task { @MainActor in
                switch event {
                case .keyDown:
                    self.note("Global hotkey down")
                    await self.handleGlobalHotkeyPress()
                case .keyUp:
                    self.note("Global hotkey up")
                    await self.handleGlobalHotkeyRelease()
                }
            }
        }
        note("Hotkey monitoring started")
    }

    func stopHotkeyMonitoring() {
        hotkeyMonitor.stop()
        isHotkeyActive = false
        note("Hotkey monitoring stopped")
    }

    func handlePrimaryAction() async {
        switch state {
        case .idle, .recorded, .error:
            await startRecording()
        case .recording:
            await forceStopRecording()
        case .transcribing, .inserting:
            break
        }
    }

    func handleGlobalHotkeyPress() async {
        guard !isHotkeyActive else {
            return
        }

        isHotkeyActive = true

        switch state {
        case .idle, .recorded, .error:
            await startRecording()
        case .recording, .transcribing, .inserting:
            break
        }
    }

    func handleGlobalHotkeyRelease() async {
        guard isHotkeyActive else {
            return
        }

        isHotkeyActive = false

        if case .recording = state {
            await stopRecording()
        }
    }

    private func startRecording() async {
        if microphonePermission == .undetermined {
            await requestMicrophoneAccess()
        } else {
            await refreshMicrophonePermission()
        }

        guard microphonePermission.canRecord else {
            machine.handle(.fail(AudioCaptureError.microphonePermissionRequired.localizedDescription))
            syncState()
            return
        }

        do {
            try await audioRecorder.startRecording()
            machine.handle(.pressHotkey)
            syncState()
            scheduleRecordingSafetyStop()
            note("Recording started")
        } catch {
            machine.handle(.fail(error.localizedDescription))
            syncState()
            note("Recording failed to start: \(error.localizedDescription)")
        }
    }

    private func stopRecording() async {
        guard case .recording = state else {
            return
        }

        recordingSafetyTask?.cancel()
        recordingSafetyTask = nil

        do {
            let summary = try await audioRecorder.stopRecording()
            lastRecording = summary
            machine.handle(.releaseHotkey)
            machine.handle(.finishRecording(summary))
            syncState()
            note("Recording stopped")
            await transcribe(summary: summary)
        } catch {
            machine.handle(.fail(error.localizedDescription))
            syncState()
            note("Recording failed to stop: \(error.localizedDescription)")
        }
    }

    private func forceStopRecording() async {
        note("Force stop requested")
        await stopRecording()
    }

    private func transcribe(summary: RecordingSummary) async {
        if transcriptionBackend.requiresSpeechRecognitionPermission {
            if speechPermission == .undetermined {
                await requestSpeechAccess()
            } else {
                await refreshSpeechPermission()
            }

            guard speechPermission.canTranscribe else {
                machine.handle(.fail("Speech recognition permission is required."))
                syncState()
                return
            }
        }

        machine.handle(.transcriptionStarted)
        syncState()
        note("Transcription started with \(transcriptionBackend.displayLabel)")

        do {
            let result = try await transcriber.transcribe(audioFileAtPath: summary.filePath)
            lastTranscript = result
            note("Transcript ready: \(result.text.prefix(40))")
            await insertTranscript(result.text)
        } catch {
            machine.handle(.fail(error.localizedDescription))
            syncState()
            note("Transcription failed: \(error.localizedDescription)")
        }
    }

    private func insertTranscript(_ text: String) async {
        machine.handle(.insertionStarted)
        syncState()
        note("Insertion started")

        do {
            try await textInserter.insert(text: text)
            lastInsertedText = text
            machine.handle(.reset)
            syncState()
            note("Insertion completed")
        } catch {
            machine.handle(.fail(error.localizedDescription))
            syncState()
            note("Insertion failed: \(error.localizedDescription)")
        }
    }

    private func syncState() {
        state = machine.state
        note("State: \(state.displayLabel)")
    }

    private func note(_ message: String) {
        lastEventDescription = message
        logger.log("\(message, privacy: .public)")
    }

    private func scheduleRecordingSafetyStop() {
        recordingSafetyTask?.cancel()
        recordingSafetyTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(15))
            guard let self else {
                return
            }
            await MainActor.run {
                self.note("Safety stop triggered")
            }
            await self.forceStopRecording()
        }
    }
}
