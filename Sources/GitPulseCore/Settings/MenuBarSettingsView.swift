import SwiftData
import SwiftUI

struct MenuBarSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "icon", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Icon style") {
                    DarkPicker(
                        options: MenuBarIconStyle.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.menuBarIconStyle
                    )
                }
                SettingsRow(label: "Color-code on CI status", subtitle: "Red when failing, orange when running") {
                    DarkToggle(isOn: $settings.colorCodeIconOnCIStatus)
                }
                SettingsRow(label: "Animate when CI running", hasDivider: false) {
                    DarkToggle(isOn: $settings.animateIconWhenCIRunning)
                }
            }

            SectionLabel(text: "badge count")
            SettingsGroup {
                SettingsRow(label: "Show count next to icon") {
                    DarkToggle(isOn: $settings.showCountInMenuBar)
                }
                SettingsRow(label: "Count type") {
                    DarkPicker(
                        options: MenuBarCountType.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.menuBarCountType
                    )
                }
                SettingsRow(label: "Hide when zero") {
                    DarkToggle(isOn: $settings.hideCountWhenZero)
                }
                SettingsRow(label: "Cap displayed count at", hasDivider: false) {
                    DarkPicker(
                        options: [
                            SelectOption(id: 10, label: "10"),
                            SelectOption(id: 99, label: "99"),
                            SelectOption(id: 999, label: "999"),
                            SelectOption(id: 0, label: "No cap")
                        ],
                        selection: $settings.menuBarCountCap
                    )
                }
            }

            SectionLabel(text: "tabs")
            SettingsGroup {
                SettingsRow(label: "Pull Requests") {
                    DarkToggle(isOn: $settings.tabPRsEnabled)
                }
                SettingsRow(label: "Issues") {
                    DarkToggle(isOn: $settings.tabIssuesEnabled)
                }
                SettingsRow(label: "CI / CD") {
                    DarkToggle(isOn: $settings.tabCICDEnabled)
                }
                SettingsRow(label: "Projects") {
                    DarkToggle(isOn: $settings.tabProjectsEnabled)
                }
                SettingsRow(label: "Mentions", hasDivider: false) {
                    DarkToggle(isOn: $settings.tabMentionsEnabled)
                }
            }
        }
        .padding(.vertical, 20)
    }
}
