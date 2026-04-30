import SwiftData
import SwiftUI

struct PollingSettingsView: View {
    @Environment(AppState.self) private var appState
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings {
        settingsArr.first!
    }

    var body: some View {
        @Bindable var settings = settings

        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "polling", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Refresh interval") {
                    DarkPicker(
                        options: PollInterval.allCases.map { SelectOption(id: $0.seconds, label: $0.displayName) },
                        selection: $settings.pollIntervalSeconds
                    )
                }
                SettingsRow(label: "Pause on battery", subtitle: "Switch to manual refresh when unplugged") {
                    DarkToggle(isOn: $settings.pausePollingOnBattery)
                }
                SettingsRow(label: "Pause when offline") {
                    DarkToggle(isOn: $settings.pausePollingWhenOffline)
                }
                SettingsRow(label: "Back off on rate limit", subtitle: "Double the interval when GitHub returns 403", hasDivider: false) {
                    DarkToggle(isOn: $settings.backoffOnRateLimit)
                }
            }

            SectionLabel(text: "webhook receiver")
            SettingsGroup {
                SettingsRow(label: "Enable webhook receiver", subtitle: "Runs a local HTTP server for instant CI events") {
                    DarkToggle(isOn: $settings.webhookEnabled)
                }
                SettingsRow(label: "Port") {
                    SettingsTextInput(placeholder: "9876", text: webhookPortText)
                        .frame(width: 70)
                        .multilineTextAlignment(.trailing)
                }
                SettingsRow(label: "Verify webhook signatures", subtitle: "Reject payloads with invalid HMAC signatures", hasDivider: false) {
                    DarkToggle(isOn: $settings.verifyWebhookSignatures)
                }
            }
            SettingsHint(text: "Configure your GitHub App webhook to forward to localhost:9876. Use smee.io in development.")

            SectionLabel(text: "status")
            SettingsGroup {
                SettingsRow(label: "Last successful poll") {
                    statusText(lastPollText)
                }
                SettingsRow(label: "Rate limit remaining", hasDivider: false) {
                    statusText(appState.rateLimitSummary)
                }
            }
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

    private var webhookPortText: Binding<String> {
        Binding(
            get: { String(settings.webhookPort) },
            set: { value in
                if let port = Int(value) {
                    settings.webhookPort = port
                }
            }
        )
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
