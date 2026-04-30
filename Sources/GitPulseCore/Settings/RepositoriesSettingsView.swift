import SwiftData
import SwiftUI

struct RepositoriesSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section("Organization Watching") {
                Toggle("Auto-watch new repositories", isOn: $settings.autoWatchNewRepos)
                TextField("Organization", text: $settings.autoWatchOrg)
                    .disabled(!settings.autoWatchNewRepos)
                Toggle("Include forks", isOn: $settings.includeForks)
                Toggle("Include archived repositories", isOn: $settings.includeArchivedRepos)
            }

            Section("Repository Rules") {
                Toggle("Watch repos I am assigned to", isOn: $settings.watchReposImAssignedTo)
                Toggle("Show only repos with activity", isOn: $settings.showOnlyReposWithActivity)
                TextField("Hide pattern", text: $settings.repoHidePattern)
            }
        }
        .formStyle(.grouped)
    }
}
