import SwiftUI

struct ShortcutsSettingsView: View {
    var body: some View {
        Form {
            Section("Global Shortcuts") {
                ForEach(GlobalShortcutDefinition.defaults, id: \.action) { definition in
                    LabeledContent(label(for: definition.action), value: definition.displayString)
                }
            }

            Section("Binding") {
                Text("These shortcuts are registered globally while GitPulse is running.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
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
