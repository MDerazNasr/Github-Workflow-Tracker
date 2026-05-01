import AppKit
import SwiftData
import SwiftUI

struct GeneralSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "app", isFirst: true)
            SettingsGroup {
                SettingsRow(
                    label: "Show in Dock",
                    subtitle: "Show or hide GitPulse in the macOS Dock",
                    hasDivider: false
                ) {
                    DarkToggle(isOn: $settings.showInDock)
                }
                    .onChange(of: settings.showInDock) { _, show in
                        NSApp.setActivationPolicy(show ? .regular : .accessory)
                    }
            }
            SettingsHint(text: "Only settings connected to current app behavior are shown here.")
        }
        .padding(.vertical, 20)
    }
}
