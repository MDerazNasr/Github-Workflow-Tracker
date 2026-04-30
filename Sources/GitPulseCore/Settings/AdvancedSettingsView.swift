import AppKit
import SwiftData
import SwiftUI

struct AdvancedSettingsView: View {
    @Query private var settingsArr: [AppSettings]
    @State private var showResetConfirmation = false
    @State private var showFullResetConfirmation = false

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        Form {
            Section("Logging") {
                Picker("Log level", selection: $settings.logLevel) {
                    ForEach(LogLevel.allCases) {
                        Text($0.displayName).tag($0.rawValue)
                    }
                }
                Toggle("Write logs to file", isOn: $settings.writeLogsToFile)
                Button("Open log file") {
                    NSWorkspace.shared.open(logFileURL)
                }
            }

            Section("Developer") {
                Toggle("Show API request log", isOn: $settings.showAPIRequestLog)
                Toggle("Simulate slow network", isOn: $settings.simulateSlowNetwork)
                Toggle("Force CI failure state", isOn: $settings.forceCIFailureState)
            }

            Section("Reset") {
                Button("Reset all settings to defaults", role: .destructive) {
                    showResetConfirmation = true
                }
                Button("Delete all data and sign out", role: .destructive) {
                    showFullResetConfirmation = true
                }
            }

            Section("About") {
                LabeledContent("Version", value: appVersion)
                Toggle("Auto-update", isOn: $settings.autoUpdate)
                Button("Check for updates") {}
                Link("View changelog", destination: changelogURL)
            }
        }
        .formStyle(.grouped)
        .confirmationDialog("Reset all settings?", isPresented: $showResetConfirmation) {
            Button("Reset Settings", role: .destructive) {
                settings.resetToDefaults()
            }
        }
        .confirmationDialog("Delete all data and sign out?", isPresented: $showFullResetConfirmation) {
            Button("Delete Data", role: .destructive) {
                settings.resetToDefaults()
            }
        }
    }

    private var logFileURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appending(path: "Library/Logs/GitPulse/gitpulse.log")
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Development"
    }

    private var changelogURL: URL {
        URL(string: "https://github.com/")!
    }
}
