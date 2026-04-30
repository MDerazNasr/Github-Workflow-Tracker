import Carbon.HIToolbox
import Foundation

public enum GlobalShortcutAction: UInt32, CaseIterable, Sendable {
    case openPopover = 1
    case refresh = 2
    case markAllRead = 3
    case openSettings = 4
}

public struct GlobalShortcutDefinition: Equatable, Sendable {
    public let action: GlobalShortcutAction
    public let keyCode: UInt32
    public let modifiers: UInt32
    public let displayString: String

    public init(
        action: GlobalShortcutAction,
        keyCode: UInt32,
        modifiers: UInt32,
        displayString: String
    ) {
        self.action = action
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.displayString = displayString
    }

    public static var defaults: [GlobalShortcutDefinition] {
        [
            .init(action: .openPopover, keyCode: 49, modifiers: UInt32(optionKey), displayString: "⌥ Space"),
            .init(action: .refresh, keyCode: 15, modifiers: UInt32(optionKey), displayString: "⌥ R"),
            .init(action: .markAllRead, keyCode: 46, modifiers: UInt32(optionKey), displayString: "⌥ M"),
            .init(action: .openSettings, keyCode: 43, modifiers: UInt32(optionKey), displayString: "⌥ ,")
        ]
    }
}
