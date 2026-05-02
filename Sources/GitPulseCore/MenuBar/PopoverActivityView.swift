import SwiftData
import SwiftUI

struct PopoverActivityView: View {
    @Environment(AppState.self) private var appState
    let activeFilter: FeedFilter
    @Query(sort: \AuthoredPullRequest.updatedAt, order: .reverse)
    private var pullRequests: [AuthoredPullRequest]
    @Query private var settingsArr: [AppSettings]

    private var settings: AppSettings? {
        settingsArr.first
    }

    var body: some View {
        content
            .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 520)
    }

    @ViewBuilder
    private var content: some View {
        if appState.pullRequestSync.isRefreshing {
            ProgressView("Refreshing PRs")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if visiblePullRequests.isEmpty && visibleDemoEvents.isEmpty {
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
                    ForEach(groupedDemoEvents, id: \.repository) { group in
                        DemoWorkflowEventSection(
                            repositoryName: group.repository,
                            events: group.events
                        )
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text(emptyTitle)
                .font(GitPulseText.mono(13))
                .foregroundColor(GitPulseColors.textFaint)
            Text(emptyMessage)
                .font(GitPulseText.mono(11))
                .foregroundColor(GitPulseColors.textGhost)
                .multilineTextAlignment(.center)
            StandardButton(title: "Refresh") {
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
        if settings?.demoMode == true {
            return "no visible demo events"
        }
        if appState.gitHubAccount.status.isConnected {
            return activeFilter == .prs || activeFilter == .all ? "no unread events" : "no \(activeFilter.label) events"
        }
        return "Connect GitHub or turn on demo activity in Settings."
    }

    private var visiblePullRequests: [AuthoredPullRequest] {
        guard activeFilter.isEnabled(in: settings) else {
            return []
        }

        switch activeFilter {
        case .all, .prs:
            guard settings?.tabPRsEnabled ?? true else {
                return []
            }
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

    private var visibleDemoEvents: [DemoWorkflowEvent] {
        guard settings?.demoMode == true else {
            return []
        }
        return DemoWorkflowEvent.samples().filter { event in
            switch activeFilter {
            case .all:
                return event.filter.isEnabled(in: settings)
            default:
                return event.filter == activeFilter && activeFilter.isEnabled(in: settings)
            }
        }
    }

    private var groupedDemoEvents: [(repository: String, events: [DemoWorkflowEvent])] {
        let grouped = Dictionary(grouping: visibleDemoEvents, by: \.repositoryName)
        return grouped
            .map { (repository: $0.key, events: $0.value.sorted { $0.updatedAt > $1.updatedAt }) }
            .sorted { $0.repository < $1.repository }
    }
}

private struct DemoWorkflowEventSection: View {
    let repositoryName: String
    let events: [DemoWorkflowEvent]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(repositoryName)
                    .font(GitPulseText.mono(10, weight: .medium))
                    .foregroundColor(GitPulseColors.textSecondary)
                CountBadge(text: "demo", tone: .gray)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 4)

            ForEach(events) { event in
                DemoWorkflowEventRow(event: event)
            }
        }
    }
}
