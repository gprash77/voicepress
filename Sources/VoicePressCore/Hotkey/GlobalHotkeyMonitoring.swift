import Foundation

public enum GlobalHotkeyEvent: Equatable, Sendable {
    case keyDown
    case keyUp
}

@MainActor
public protocol GlobalHotkeyMonitoring: AnyObject {
    func start(handler: @escaping @Sendable (GlobalHotkeyEvent) -> Void)
    func stop()
}
