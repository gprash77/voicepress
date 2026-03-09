import Foundation

public enum TextInsertionError: LocalizedError, Equatable, Sendable {
    case emptyText
    case pasteboardUnavailable
    case pasteCommandFailed

    public var errorDescription: String? {
        switch self {
        case .emptyText:
            "There is no text to insert."
        case .pasteboardUnavailable:
            "The pasteboard is unavailable."
        case .pasteCommandFailed:
            "The paste command could not be sent to the focused app."
        }
    }
}
