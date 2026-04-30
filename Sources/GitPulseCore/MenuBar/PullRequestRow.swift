import SwiftUI

struct PullRequestRow: View {
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
