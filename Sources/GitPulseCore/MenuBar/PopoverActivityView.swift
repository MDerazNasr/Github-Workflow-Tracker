import SwiftData
import SwiftUI

struct PopoverActivityView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \AuthoredPullRequest.updatedAt, order: .reverse)
    private var pullRequests: [AuthoredPullRequest]

    var body: some View {
        content
            .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 360)
    }

    @ViewBuilder
    private var content: some View {
        if appState.pullRequestSync.isRefreshing {
            ProgressView("Refreshing PRs")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if pullRequests.isEmpty {
            emptyState
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

    private var emptyState: some View {
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
