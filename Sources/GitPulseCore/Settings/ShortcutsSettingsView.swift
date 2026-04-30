import SwiftData
import SwiftUI

struct ShortcutsSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section("Global Shortcuts") {
                TextField("Open popover", text: $settings.shortcutOpenPopover)
                TextField("Refresh", text: $settings.shortcutRefresh)
                TextField("Mark all read", text: $settings.shortcutMarkAllRead)
                TextField("Open settings", text: $settings.shortcutOpenSettings)
            }

            Section("Binding") {
                Text("These strings are display values. Global shortcut registration belongs in the KeyboardShortcuts integration.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}
