import SwiftData
import SwiftUI

struct RepositoriesSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "watching", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Authored PRs", subtitle: "Repos with open PRs you authored appear automatically", hasDivider: false) {
                    CountBadge(text: "auto", tone: .blue)
                }
            }

            SectionLabel(text: "organization watching")
            SettingsGroup {
                SettingsRow(
                    label: "Auto-watch new repos in org",
                    subtitle: "New repos in your org are added automatically"
                ) {
                    DarkToggle(isOn: $settings.autoWatchNewRepos)
                }
                SettingsRow(label: "Organization") {
                    SettingsTextInput(placeholder: "org", text: $settings.autoWatchOrg)
                        .frame(width: 140)
                }
                SettingsRow(label: "Include forks") {
                    DarkToggle(isOn: $settings.includeForks)
                }
                SettingsRow(label: "Include archived repos") {
                    DarkToggle(isOn: $settings.includeArchivedRepos)
                }
                SettingsRow(
                    label: "Watch repos I am assigned to",
                    subtitle: "Auto-add repos when you are assigned an issue or PR",
                    hasDivider: false
                ) {
                    DarkToggle(isOn: $settings.watchReposImAssignedTo)
                }
            }

            SectionLabel(text: "filters")
            SettingsGroup {
                SettingsRow(
                    label: "Show only repos with activity",
                    subtitle: "Hide repos with no unread events from the feed"
                ) {
                    DarkToggle(isOn: $settings.showOnlyReposWithActivity)
                }
                SettingsRow(label: "Hide repos matching", hasDivider: false) {
                    SettingsTextInput(placeholder: "e.g. *-archive", text: $settings.repoHidePattern)
                        .frame(width: 140)
                }
            }
        }
        .padding(.vertical, 20)
    }
}
