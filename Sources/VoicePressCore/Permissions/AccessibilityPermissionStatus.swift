import Foundation

public enum AccessibilityPermissionStatus: Equatable, Sendable {
    case denied
    case granted

    public var displayLabel: String {
        switch self {
        case .denied:
            "Denied"
        case .granted:
            "Granted"
        }
    }

    public var canMonitorGlobalInput: Bool {
        self == .granted
    }
}
