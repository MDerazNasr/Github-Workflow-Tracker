import SwiftData
import SwiftUI

public struct PopoverRootView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(AppState.self) private var appState
    @Query private var settingsArr: [AppSettings]
    @Query(sort: \AuthoredPullRequest.updatedAt, order: .reverse)
    private var pullRequests: [AuthoredPullRequest]

    public init() {}

    private var settings: AppSettings? {
        settingsArr.first
    }

    public var body: some View {
        if let settings {
            @Bindable var settings = settings

            content(settings: settings, notificationsEnabled: $settings.notificationsEnabled)
        } else {
            content(settings: nil, notificationsEnabled: .constant(true))
        }
    }

    private func content(settings: AppSettings?, notificationsEnabled: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("GitPulse")
                    .font(.headline)
                Spacer()
                Button {
                    openSettings()
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.borderless)
                .help("Open Settings")
            }

            pullRequestContent
                .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 360)

            Divider()

            Toggle(
                "Notifications",
                isOn: notificationsEnabled
            )
        }
        .padding(16)
        .frame(width: CGFloat(settings?.popoverWidth ?? 360))
    }

    @ViewBuilder
    private var pullRequestContent: some View {
        if appState.pullRequestSync.isRefreshing {
            ProgressView("Refreshing PRs")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if pullRequests.isEmpty {
            VStack(spacing: 8) {
                Text(emptyTitle)
                    .font(.headline)
                Text(emptyMessage)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button("Refresh") {
                    Task {
                        await appState.refreshAuthoredPullRequests()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(pullRequests) { pullRequest in
                        PullRequestRow(pullRequest: pullRequest)
                        if pullRequest.githubID != pullRequests.last?.githubID {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var emptyTitle: String {
        appState.gitHubAccount.status.isConnected ? "No open PRs" : "Connect GitHub"
    }

    private var emptyMessage: String {
        if let error = appState.pullRequestSync.lastErrorMessage {
            return error
        }
        if appState.gitHubAccount.status.isConnected {
            return "Open pull requests you authored will appear here after refresh."
        }
        return "Connect your account in Settings to show your open pull requests."
    }
}

private struct PullRequestRow: View {
    let pullRequest: AuthoredPullRequest

    var body: some View {
        Link(destination: pullRequest.url) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: pullRequest.checkStatus.systemImage)
                    .foregroundStyle(statusColor)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 4) {
                    Text(pullRequest.title)
                        .font(.body)
                        .lineLimit(2)
                    Text("\(pullRequest.repositoryName) #\(pullRequest.number)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 6) {
                        Text(pullRequest.checkStatus.displayName)
                        Text(pullRequest.reviewStatus.displayName)
                        if !pullRequest.branchName.isEmpty {
                            Text(pullRequest.branchName)
                                .lineLimit(1)
                        }
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var statusColor: Color {
        switch pullRequest.checkStatus {
        case .passing: return .green
        case .failing: return .red
        case .pending, .expected: return .orange
        case .unknown: return .secondary
        }
    }
}
