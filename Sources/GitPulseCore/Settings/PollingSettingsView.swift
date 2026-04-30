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

        Form {
            Section("Polling") {
                Picker("Refresh interval", selection: $settings.pollIntervalSeconds) {
                    ForEach(PollInterval.allCases) {
                        Text($0.displayName).tag($0.seconds)
                    }
                }
                Toggle("Pause on battery", isOn: $settings.pausePollingOnBattery)
                Toggle("Pause when offline", isOn: $settings.pausePollingWhenOffline)
                Toggle("Back off on rate limit", isOn: $settings.backoffOnRateLimit)
            }

            Section("Webhook Receiver") {
                Toggle("Enable webhook receiver", isOn: $settings.webhookEnabled)
                if settings.webhookEnabled {
                    LabeledContent("Port") {
                        TextField("Port", value: $settings.webhookPort, format: .number)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    Toggle("Verify signatures", isOn: $settings.verifyWebhookSignatures)
                }
            }

            Section("Status") {
                LabeledContent("Last poll", value: lastPollText)
                LabeledContent("Rate limit", value: appState.rateLimitSummary)
                Button("Poll now") {
                    Task {
                        await appState.refreshAuthoredPullRequests()
                    }
                }
                .disabled(appState.pullRequestSync.isRefreshing)
            }
        }
        .formStyle(.grouped)
    }

    private var lastPollText: String {
        guard let date = appState.lastPollDate else {
            return "Never"
        }
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
