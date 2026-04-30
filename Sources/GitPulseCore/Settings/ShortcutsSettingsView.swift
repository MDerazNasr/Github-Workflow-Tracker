import SwiftUI

struct ShortcutsSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "global shortcuts", isFirst: true)
            SettingsGroup {
                ForEach(GlobalShortcutDefinition.defaults, id: \.action) { definition in
                    SettingsRow(label: label(for: definition.action), hasDivider: definition.action != .openSettings) {
                        KbdBadge(shortcut: definition.displayString)
                    }
                }
            }

            SectionLabel(text: "in-popover shortcuts")
            SettingsGroup {
                SettingsRow(label: "Navigate items") { KbdBadge(shortcut: "↑ ↓") }
                SettingsRow(label: "Open selected item") { KbdBadge(shortcut: "↵") }
                SettingsRow(label: "Mark selected read") { KbdBadge(shortcut: "E") }
                SettingsRow(label: "Dismiss selected") { KbdBadge(shortcut: "D") }
                SettingsRow(label: "Switch tab left / right") { KbdBadge(shortcut: "[ ]") }
                SettingsRow(label: "Close popover", hasDivider: false) { KbdBadge(shortcut: "Esc") }
            }
            SettingsHint(text: "Global shortcuts require Accessibility permission in System Settings -> Privacy & Security.")
        }
        .padding(.vertical, 20)
    }

    private func label(for action: GlobalShortcutAction) -> String {
        switch action {
        case .openPopover: return "Open popover"
        case .refresh: return "Refresh"
        case .markAllRead: return "Mark all read"
        case .openSettings: return "Open settings"
        }
    }
}
