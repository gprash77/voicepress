import Foundation

public enum MicrophonePermissionStatus: Equatable, Sendable {
    case undetermined
    case denied
    case restricted
    case granted

    public var displayLabel: String {
        switch self {
        case .undetermined:
            "Not Requested"
        case .denied:
            "Denied"
        case .restricted:
            "Restricted"
        case .granted:
            "Granted"
        }
    }

    public var canRecord: Bool {
        self == .granted
    }
}
