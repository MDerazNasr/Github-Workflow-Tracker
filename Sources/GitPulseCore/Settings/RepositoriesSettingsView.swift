import SwiftData
import SwiftUI

struct RepositoriesSettingsView: View {
    @Query private var pullRequests: [AuthoredPullRequest]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionLabel(text: "watching", isFirst: true)
            SettingsGroup {
                SettingsRow(label: "Authored PRs", subtitle: "Repos with open PRs you authored appear automatically") {
                    CountBadge(text: "auto", tone: .blue)
                }
                SettingsRow(
                    label: "Tracked repositories",
                    subtitle: "Based on the PRs currently stored from GitHub",
                    hasDivider: false
                ) {
                    CountBadge(text: "\(repositoryCount)", tone: repositoryCount == 0 ? .gray : .green)
                }
            }
            SettingsHint(text: "Organization watching and repository filters were removed until those GitHub queries exist.")
        }
        .padding(.vertical, 20)
    }

    private var repositoryCount: Int {
        Set(pullRequests.map(\.repositoryName)).count
    }
}
