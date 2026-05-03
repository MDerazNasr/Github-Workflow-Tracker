import AppKit
import SwiftData
import SwiftUI

struct AdvancedSettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppState.self) private var appState
    @Query private var settingsArr: [AppSettings]
    @State private var showResetConfirmation = false
    @State private var showFullResetConfirmation = false
    @State private var showClearPullRequestsConfirmation = false

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "cache", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Stored pull requests", subtitle: "Clear the local cache and fetch again when needed", hasDivider: false) {
                    DangerButton(title: "Clear") {
                        showClearPullRequestsConfirmation = true
                    }
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
                SettingsRow(label: "View changelog", hasDivider: false) {
                    StandardButton(title: "Open") {
                        NSWorkspace.shared.open(changelogURL)
                    }
                }
            }
        }
        .padding(.vertical, 20)
        .confirmationDialog("Reset all settings?", isPresented: $showResetConfirmation) {
            Button("Reset Settings", role: .destructive) {
                settings.resetToDefaults()
                appState.applyRuntimeSettings(settings)
                appState.reloadGlobalShortcuts()
            }
        }
        .confirmationDialog("Clear stored pull requests?", isPresented: $showClearPullRequestsConfirmation) {
            Button("Clear Pull Requests", role: .destructive) {
                clearPullRequests()
            }
        }
        .confirmationDialog("Delete all data and sign out?", isPresented: $showFullResetConfirmation) {
            Button("Delete Data", role: .destructive) {
                settings.resetToDefaults()
                appState.applyRuntimeSettings(settings)
                appState.reloadGlobalShortcuts()
                clearPullRequests()
                appState.gitHubAccount.signOut()
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Development"
    }

    private var changelogURL: URL {
        URL(string: "https://github.com/")!
    }

    private func clearPullRequests() {
        let descriptor = FetchDescriptor<AuthoredPullRequest>()
        guard let pullRequests = try? context.fetch(descriptor) else {
            return
        }

        for pullRequest in pullRequests {
            context.delete(pullRequest)
        }
        try? context.save()
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
