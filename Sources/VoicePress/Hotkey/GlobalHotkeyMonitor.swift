import ApplicationServices
import Foundation
import VoicePressCore

@MainActor
final class GlobalHotkeyMonitor: GlobalHotkeyMonitoring {
    private let keyCode: CGKeyCode
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var handler: (@Sendable (GlobalHotkeyEvent) -> Void)?

    init(keyCode: CGKeyCode = 97) {
        self.keyCode = keyCode
    }

    func start(handler: @escaping @Sendable (GlobalHotkeyEvent) -> Void) {
        stop()
        self.handler = handler

        let mask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
        let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { _, type, event, userInfo in
                guard let userInfo else {
                    return Unmanaged.passUnretained(event)
                }

                let monitor = Unmanaged<GlobalHotkeyMonitor>.fromOpaque(userInfo).takeUnretainedValue()
                monitor.handle(event: event, type: type)
                return Unmanaged.passUnretained(event)
            },
            userInfo: userInfo
        ) else {
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        self.eventTap = eventTap
        self.runLoopSource = source

        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        handler = nil
    }

    private func handle(event: CGEvent, type: CGEventType) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            reenableEventTap()
            return
        }

        guard event.getIntegerValueField(.keyboardEventKeycode) == Int64(keyCode) else {
            return
        }

        switch type {
        case .keyDown:
            handler?(.keyDown)
        case .keyUp:
            handler?(.keyUp)
        default:
            break
        }
    }

    private func reenableEventTap() {
        guard let eventTap else {
            return
        }
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
}
