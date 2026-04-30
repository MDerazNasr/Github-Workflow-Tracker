import SwiftData
import SwiftUI

struct MenuBarSettingsView: View {
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section("Icon") {
                Picker("Icon style", selection: $settings.menuBarIconStyle) {
                    ForEach(MenuBarIconStyle.allCases) {
                        Text($0.displayName).tag($0.rawValue)
                    }
                }
                Toggle("Color-code on CI status", isOn: $settings.colorCodeIconOnCIStatus)
                Toggle("Animate when CI running", isOn: $settings.animateIconWhenCIRunning)
            }

            Section("Badge") {
                Toggle("Show count", isOn: $settings.showCountInMenuBar)
                Picker("Count type", selection: $settings.menuBarCountType) {
                    ForEach(MenuBarCountType.allCases) {
                        Text($0.displayName).tag($0.rawValue)
                    }
                }
                Toggle("Hide when zero", isOn: $settings.hideCountWhenZero)
                Picker("Cap at", selection: $settings.menuBarCountCap) {
                    Text("10").tag(10)
                    Text("99").tag(99)
                    Text("999").tag(999)
                    Text("No cap").tag(0)
                }
            }

            Section("Tabs") {
                Toggle("Pull Requests", isOn: $settings.tabPRsEnabled)
                Toggle("Issues", isOn: $settings.tabIssuesEnabled)
                Toggle("CI / CD", isOn: $settings.tabCICDEnabled)
                Toggle("Projects", isOn: $settings.tabProjectsEnabled)
                Toggle("Mentions", isOn: $settings.tabMentionsEnabled)
            }
        }
        .formStyle(.grouped)
    }
}
