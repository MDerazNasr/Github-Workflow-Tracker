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

        Form {
            Section("Startup") {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Toggle("Show in Dock", isOn: $settings.showInDock)
                    .onChange(of: settings.showInDock) { _, show in
                        NSApp.setActivationPolicy(show ? .regular : .accessory)
                    }
                Toggle("Reopen last view on launch", isOn: $settings.reopenLastViewOnLaunch)
            }

            Section("Behavior") {
                Picker("Open links in", selection: $settings.openLinksIn) {
                    ForEach(OpenLinksIn.allCases) {
                        Text($0.displayName).tag($0.rawValue)
                    }
                }
                Toggle("Mark as read on open", isOn: $settings.markAsReadOnOpen)
                Toggle("Close popover after opening link", isOn: $settings.closePopoverAfterOpeningLink)
                Toggle("Group activity by repository", isOn: $settings.groupByRepo)
                Picker("Default tab", selection: $settings.defaultTab) {
                    ForEach(AppDefaultTab.allCases) {
                        Text($0.displayName).tag($0.rawValue)
                    }
                }
            }

            Section("Data") {
                Picker("Keep read items for", selection: $settings.retentionDaysRead) {
                    Text("1 day").tag(1)
                    Text("7 days").tag(7)
                    Text("30 days").tag(30)
                    Text("90 days").tag(90)
                    Text("Forever").tag(0)
                }
                Picker("Keep dismissed items for", selection: $settings.retentionDaysDismissed) {
                    Text("Never").tag(0)
                    Text("7 days").tag(7)
                    Text("30 days").tag(30)
                }
                Toggle("Demo mode", isOn: $settings.demoMode)
            }
        }
        .formStyle(.grouped)
    }
}
