import Carbon.HIToolbox
import Foundation

public enum GlobalShortcutAction: UInt32, CaseIterable, Sendable {
    case openPopover = 1
    case refresh = 2
    case markAllRead = 3
    case openSettings = 4

    var label: String {
        switch self {
        case .openPopover: return "Open popover"
        case .refresh: return "Refresh"
        case .markAllRead: return "Mark all read"
        case .openSettings: return "Open settings"
        }
    }
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

    static func definitions(from settings: AppSettings) -> [GlobalShortcutDefinition] {
        GlobalShortcutAction.allCases.map { action in
            parse(action: action, displayString: settings.shortcutDisplay(for: action))
                ?? defaultDefinition(for: action)
        }
    }

    public static func defaultDefinition(for action: GlobalShortcutAction) -> GlobalShortcutDefinition {
        defaults.first { $0.action == action }!
    }

    public static func parse(
        action: GlobalShortcutAction,
        displayString: String
    ) -> GlobalShortcutDefinition? {
        let tokens = displayString
            .split(separator: " ")
            .map(String.init)

        guard let keyToken = tokens.last, let keyCode = KeyCodeMap.keyCode(for: keyToken) else {
            return nil
        }

        let modifierTokens = tokens.dropLast()
        let modifiers = modifierTokens.reduce(UInt32(0)) { result, token in
            result | KeyCodeMap.modifier(for: token)
        }

        guard modifiers != 0 else {
            return nil
        }

        return GlobalShortcutDefinition(
            action: action,
            keyCode: keyCode,
            modifiers: modifiers,
            displayString: displayString
        )
    }
}

extension AppSettings {
    func shortcutDisplay(for action: GlobalShortcutAction) -> String {
        switch action {
        case .openPopover: return shortcutOpenPopover
        case .refresh: return shortcutRefresh
        case .markAllRead: return shortcutMarkAllRead
        case .openSettings: return shortcutOpenSettings
        }
    }

    func setShortcutDisplay(_ displayString: String, for action: GlobalShortcutAction) {
        switch action {
        case .openPopover: shortcutOpenPopover = displayString
        case .refresh: shortcutRefresh = displayString
        case .markAllRead: shortcutMarkAllRead = displayString
        case .openSettings: shortcutOpenSettings = displayString
        }
    }
}

enum KeyCodeMap {
    static func modifier(for token: String) -> UInt32 {
        switch token {
        case "⌘": return UInt32(cmdKey)
        case "⌥": return UInt32(optionKey)
        case "⌃": return UInt32(controlKey)
        case "⇧": return UInt32(shiftKey)
        default: return 0
        }
    }

    static func keyCode(for token: String) -> UInt32? {
        keyCodes[token.uppercased()]
    }

    static func keyLabel(for keyCode: UInt16) -> String? {
        keyLabels[UInt32(keyCode)]
    }

    private static let keyCodes: [String: UInt32] = [
        "A": 0, "S": 1, "D": 2, "F": 3, "H": 4, "G": 5, "Z": 6, "X": 7,
        "C": 8, "V": 9, "B": 11, "Q": 12, "W": 13, "E": 14, "R": 15,
        "Y": 16, "T": 17, "1": 18, "2": 19, "3": 20, "4": 21, "6": 22,
        "5": 23, "=": 24, "9": 25, "7": 26, "-": 27, "8": 28, "0": 29,
        "]": 30, "O": 31, "U": 32, "[": 33, "I": 34, "P": 35, "L": 37,
        "J": 38, "'": 39, "K": 40, ";": 41, "\\": 42, ",": 43, "/": 44,
        "N": 45, "M": 46, ".": 47, "`": 50, "SPACE": 49, "TAB": 48,
        "ESC": 53, "RETURN": 36, "↩": 36, "←": 123, "→": 124, "↓": 125, "↑": 126
    ]

    private static let keyLabels: [UInt32: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
        8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
        23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
        30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
        38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
        45: "N", 46: "M", 47: ".", 48: "Tab", 49: "Space", 50: "`",
        53: "Esc", 36: "Return", 123: "←", 124: "→", 125: "↓", 126: "↑"
    ]
}
