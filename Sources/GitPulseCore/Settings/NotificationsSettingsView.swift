import SwiftData
import SwiftUI

struct NotificationsSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "visible activity", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Pull requests") {
                    DarkToggle(isOn: $settings.tabPRsEnabled)
                }
                SettingsRow(label: "Issues") {
                    DarkToggle(isOn: $settings.tabIssuesEnabled)
                }
                SettingsRow(label: "CI / CD") {
                    DarkToggle(isOn: $settings.tabCICDEnabled)
                }
                SettingsRow(label: "Mentions", hasDivider: false) {
                    DarkToggle(isOn: $settings.tabMentionsEnabled)
                }
            }
            SettingsHint(text: "These controls show or hide activity types in the menu bar popover.")
        }
        .padding(.vertical, 20)
    }
}
