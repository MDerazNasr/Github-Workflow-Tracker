import SwiftUI

struct PollingSettingsView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "status")
            SettingsGroup {
                SettingsRow(label: "Last successful poll") {
                    statusText(lastPollText)
                }
                SettingsRow(label: "Rate limit remaining", hasDivider: false) {
                    statusText(appState.rateLimitSummary)
                }
            }
            SettingsHint(text: "Polling is currently manual and runs when you press Poll now or the refresh shortcut.")
            StandardButton(title: appState.pullRequestSync.isRefreshing ? "Polling" : "Poll now") {
                Task {
                    await appState.refreshAuthoredPullRequests()
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 8)
            .disabled(appState.pullRequestSync.isRefreshing)
        }
        .padding(.vertical, 20)
    }

    private func statusText(_ value: String) -> some View {
        Text(value)
            .font(GitPulseText.mono(12))
            .foregroundColor(GitPulseColors.textSecondary)
    }

    private var lastPollText: String {
        guard let date = appState.lastPollDate else {
            return "Never"
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
