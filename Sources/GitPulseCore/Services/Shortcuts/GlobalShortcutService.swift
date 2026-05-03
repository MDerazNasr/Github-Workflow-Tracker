import Carbon.HIToolbox
import Foundation

@MainActor
public final class GlobalShortcutService {
    private var hotKeyRefs: [EventHotKeyRef] = []
    private var eventHandlerRef: EventHandlerRef?
    private var actions: [GlobalShortcutAction: @MainActor () -> Void] = [:]
    public private(set) var failedDefinitions: [GlobalShortcutDefinition] = []

    public init() {}

    public func register(
        definitions: [GlobalShortcutDefinition],
        openPopover: @escaping @MainActor () -> Void,
        refresh: @escaping @MainActor () -> Void,
        markAllRead: @escaping @MainActor () -> Void,
        openSettings: @escaping @MainActor () -> Void
    ) {
        actions = [
            .openPopover: openPopover,
            .refresh: refresh,
            .markAllRead: markAllRead,
            .openSettings: openSettings
        ]
        installHandlerIfNeeded()

        for definition in definitions {
            register(definition)
        }
    }

    private func installHandlerIfNeeded() {
        guard eventHandlerRef == nil else {
            return
        }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        InstallEventHandler(
            GetApplicationEventTarget(),
            globalShortcutHandler,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
    }

    public func unregisterAll() {
        for ref in hotKeyRefs {
            UnregisterEventHotKey(ref)
        }
        hotKeyRefs.removeAll()
        failedDefinitions.removeAll()

        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
            self.eventHandlerRef = nil
        }
    }

    private func register(_ definition: GlobalShortcutDefinition) {
        var hotKeyRef: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(
            signature: fourCharacterCode("GPHT"),
            id: definition.action.rawValue
        )

        let status = RegisterEventHotKey(
            definition.keyCode,
            definition.modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if status == noErr, let hotKeyRef {
            hotKeyRefs.append(hotKeyRef)
        } else {
            failedDefinitions.append(definition)
        }
    }

    fileprivate func handle(actionID: UInt32) {
        guard let action = GlobalShortcutAction(rawValue: actionID) else {
            return
        }
        actions[action]?()
    }
}

private func globalShortcutHandler(
    nextHandler: EventHandlerCallRef?,
    event: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let event, let userData else {
        return noErr
    }

    var hotKeyID = EventHotKeyID()
    GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    let service = Unmanaged<GlobalShortcutService>.fromOpaque(userData).takeUnretainedValue()
    DispatchQueue.main.async {
        service.handle(actionID: hotKeyID.id)
    }

    return noErr
}

private func fourCharacterCode(_ string: String) -> OSType {
    string.utf8.reduce(0) { code, character in
        (code << 8) + OSType(character)
    }
}
