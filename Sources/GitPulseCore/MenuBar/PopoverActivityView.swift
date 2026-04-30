import SwiftData
import SwiftUI

struct PopoverActivityView: View {
    @Environment(AppState.self) private var appState
    let activeFilter: FeedFilter
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
        } else if visiblePullRequests.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(groupedPullRequests, id: \.repository) { group in
                        RepoPullRequestSection(
                            repositoryName: group.repository,
                            pullRequests: group.pullRequests
                        )
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
        appState.gitHubAccount.status.isConnected ? "all clear" : "connect github"
    }

    private var emptyMessage: String {
        if let error = appState.pullRequestSync.lastErrorMessage {
            return error
        }
        if appState.gitHubAccount.status.isConnected {
            return activeFilter == .prs || activeFilter == .all ? "no unread events" : "no \(activeFilter.label) events"
        }
        return "Connect your account in Settings to show your open pull requests."
    }

    private var visiblePullRequests: [AuthoredPullRequest] {
        switch activeFilter {
        case .all, .prs:
            return pullRequests
        case .issues, .cicd, .mentions:
            return []
        }
    }

    private var groupedPullRequests: [(repository: String, pullRequests: [AuthoredPullRequest])] {
        let grouped = Dictionary(grouping: visiblePullRequests, by: \.repositoryName)
        return grouped
            .map { (repository: $0.key, pullRequests: $0.value.sorted { $0.updatedAt > $1.updatedAt }) }
            .sorted { $0.repository < $1.repository }
    }
}
