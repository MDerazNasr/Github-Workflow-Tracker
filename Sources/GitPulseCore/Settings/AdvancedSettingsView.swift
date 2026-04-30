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

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "logging", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Log level") {
                    DarkPicker(
                        options: LogLevel.allCases.map { SelectOption(id: $0.rawValue, label: $0.displayName) },
                        selection: $settings.logLevel
                    )
                }
                SettingsRow(label: "Write logs to file", subtitle: "~/Library/Logs/GitPulse/gitpulse.log") {
                    DarkToggle(isOn: $settings.writeLogsToFile)
                }
                SettingsRow(label: "Open log file", hasDivider: false) {
                    StandardButton(title: "Open") {
                        NSWorkspace.shared.open(logFileURL)
                    }
                }
            }

            SectionLabel(text: "developer")
            SettingsGroup {
                SettingsRow(label: "Show API request log", subtitle: "Overlay showing every GitHub API call in real time") {
                    DarkToggle(isOn: $settings.showAPIRequestLog)
                }
                SettingsRow(label: "Simulate slow network", subtitle: "Adds 2s latency to all API calls") {
                    DarkToggle(isOn: $settings.simulateSlowNetwork)
                }
                SettingsRow(label: "Force CI failure state", subtitle: "Overrides all CI status to failing, tests icon color", hasDivider: false) {
                    DarkToggle(isOn: $settings.forceCIFailureState)
                }
            }

            SectionLabel(text: "cache")
            SettingsGroup {
                SettingsRow(label: "Cache size") {
                    valueText("0 KB")
                }
                SettingsRow(label: "Clear cache", hasDivider: false) {
                    DangerButton(title: "Clear") {}
                }
            }

            SectionLabel(text: "reset")
            SettingsGroup {
                DangerRow(label: "Reset all settings to defaults") {
                    showResetConfirmation = true
                }
                DangerRow(label: "Delete all data and sign out", hasDivider: false) {
                    showFullResetConfirmation = true
                }
            }

            SectionLabel(text: "about")
            SettingsGroup {
                SettingsRow(label: "Version") {
                    valueText(appVersion)
                }
                SettingsRow(label: "Auto-update") {
                    DarkToggle(isOn: $settings.autoUpdate)
                }
                SettingsRow(label: "Check for updates") {
                    StandardButton(title: "Check now") {}
                }
                SettingsRow(label: "View changelog", hasDivider: false) {
                    StandardButton(title: "Open ↗") {
                        NSWorkspace.shared.open(changelogURL)
                    }
                }
            }
        }
        .padding(.vertical, 20)
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

    private func valueText(_ value: String) -> some View {
        Text(value)
            .font(GitPulseText.mono(12))
            .foregroundColor(GitPulseColors.textSecondary)
    }
}

private struct DangerRow: View {
    let label: String
    var hasDivider = true
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Text(label)
                        .font(GitPulseText.mono(12))
                        .foregroundColor(GitPulseColors.red)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(minHeight: 44)
            }
            .buttonStyle(.plain)

            if hasDivider {
                Rectangle()
                    .fill(GitPulseColors.dividerStrong)
                    .frame(height: 0.5)
                    .padding(.leading, 14)
            }
        }
    }
}
