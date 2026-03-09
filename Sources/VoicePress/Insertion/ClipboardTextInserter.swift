import AppKit
import Foundation
import VoicePressCore

@MainActor
final class ClipboardTextInserter: TextInserting {
    private let pasteboard: NSPasteboard
    private let restoreDelayNanoseconds: UInt64

    init(
        pasteboard: NSPasteboard = .general,
        restoreDelayNanoseconds: UInt64 = 350_000_000
    ) {
        self.pasteboard = pasteboard
        self.restoreDelayNanoseconds = restoreDelayNanoseconds
    }

    func insert(text: String) async throws {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TextInsertionError.emptyText
        }

        let snapshot = pasteboard.string(forType: .string)
        guard pasteboard.clearContents() != 0 else {
            throw TextInsertionError.pasteboardUnavailable
        }

        guard pasteboard.setString(trimmed, forType: .string) else {
            throw TextInsertionError.pasteboardUnavailable
        }

        do {
            try sendPasteCommand()
        } catch {
            restore(snapshot: snapshot)
            throw error
        }

        try? await Task.sleep(nanoseconds: restoreDelayNanoseconds)
        restore(snapshot: snapshot)
    }

    private func restore(snapshot: String?) {
        pasteboard.clearContents()

        if let snapshot {
            pasteboard.setString(snapshot, forType: .string)
        }
    }

    private func sendPasteCommand() throws {
        guard
            let source = CGEventSource(stateID: .combinedSessionState),
            let keyDown = CGEvent(
                keyboardEventSource: source,
                virtualKey: CGKeyCode(9),
                keyDown: true
            ),
            let keyUp = CGEvent(
                keyboardEventSource: source,
                virtualKey: CGKeyCode(9),
                keyDown: false
            )
        else {
            throw TextInsertionError.pasteCommandFailed
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
