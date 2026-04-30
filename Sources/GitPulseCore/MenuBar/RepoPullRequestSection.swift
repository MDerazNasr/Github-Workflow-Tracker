import SwiftUI

struct RepoPullRequestSection: View {
    let repositoryName: String
    let pullRequests: [AuthoredPullRequest]
    @State private var expanded = true

    var body: some View {
        VStack(spacing: 0) {
            Button {
                expanded.toggle()
            } label: {
                HStack(spacing: 7) {
                    StatusDot(color: worstStatusColor, size: 7)
                    Text(repositoryName)
                        .font(GitPulseText.mono(12))
                        .foregroundColor(GitPulseColors.textPrimary)
                    Spacer()
                    CountBadge(text: "\(pullRequests.count) prs", tone: .blue)
                    if pullRequests.contains(where: { $0.checkStatus == .failing }) {
                        CountBadge(text: "ci fail", tone: .red)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 6)
            }
            .buttonStyle(.plain)

            if expanded {
                ForEach(pullRequests) { pullRequest in
                    PullRequestRow(pullRequest: pullRequest)
                }
            }

            Rectangle()
                .fill(GitPulseColors.divider)
                .frame(height: 0.5)
        }
    }

    private var worstStatusColor: Color {
        if pullRequests.contains(where: { $0.checkStatus == .failing }) {
            return GitPulseColors.red
        }
        if pullRequests.contains(where: { $0.checkStatus == .pending || $0.checkStatus == .expected }) {
            return GitPulseColors.amber
        }
        if pullRequests.contains(where: { $0.checkStatus == .passing }) {
            return GitPulseColors.green
        }
        return GitPulseColors.textFaint
    }
}
