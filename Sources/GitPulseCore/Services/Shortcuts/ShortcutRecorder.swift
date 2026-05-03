import AppKit
import Carbon.HIToolbox
import Foundation

enum ShortcutRecorder {
    static func displayString(from event: NSEvent) -> String? {
        guard let keyLabel = KeyCodeMap.keyLabel(for: event.keyCode) else {
            return nil
        }

        var tokens: [String] = []
        let flags = event.modifierFlags

        if flags.contains(.control) {
            tokens.append("⌃")
        }
        if flags.contains(.option) {
            tokens.append("⌥")
        }
        if flags.contains(.shift) {
            tokens.append("⇧")
        }
        if flags.contains(.command) {
            tokens.append("⌘")
        }

        guard !tokens.isEmpty else {
            return nil
        }

        tokens.append(keyLabel)
        return tokens.joined(separator: " ")
    }
}
