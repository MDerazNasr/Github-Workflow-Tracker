import SwiftData
import SwiftUI

struct GeneralSettingsView: View {
    @Environment(AppState.self) private var appState
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "app", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Appearance") {
                    DarkPicker(
                        options: AppAppearance.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.appearanceMode
                    )
                }
                .onChange(of: settings.appearanceMode) { _, _ in
                    appState.applyRuntimeSettings(settings)
                }
                SettingsRow(
                    label: "Show in Dock",
                    subtitle: "Show or hide GitPulse in the macOS Dock",
                    hasDivider: false
                ) {
                    DarkToggle(isOn: $settings.showInDock)
                }
                    .onChange(of: settings.showInDock) { _, _ in
                        appState.applyRuntimeSettings(settings)
                    }
            }
            SettingsHint(text: "Only settings connected to current app behavior are shown here.")
        }
        .padding(.vertical, 20)
    }
}
