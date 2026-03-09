import Foundation

@MainActor
public protocol AccessibilityPermissionManaging: AnyObject {
    func currentStatus() async -> AccessibilityPermissionStatus
    func requestAccess() async -> AccessibilityPermissionStatus
}
