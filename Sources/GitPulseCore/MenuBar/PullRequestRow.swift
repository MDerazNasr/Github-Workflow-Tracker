import SwiftUI

struct PullRequestRow: View {
    let pullRequest: AuthoredPullRequest
    @State private var isHovered = false

    var body: some View {
        Link(destination: pullRequest.url) {
            ZStack(alignment: .topLeading) {
                HStack(alignment: .top, spacing: 10) {
                    StatusDot(color: statusColor, size: 5)
                        .padding(.top, 5)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(pullRequest.title)
                            .font(GitPulseText.mono(12))
                            .foregroundColor(GitPulseColors.textPrimary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        HStack(spacing: 8) {
                            Text("@\(pullRequest.authorLogin)")
                                .font(GitPulseText.mono(10))
                                .foregroundColor(GitPulseColors.textMuted)
                            CountBadge(text: attentionState.displayName.lowercased(), tone: badgeTone)
                        }
                    }

                    Spacer()

                    Text(relativeTime)
                        .font(GitPulseText.mono(10))
                        .foregroundColor(GitPulseColors.textFaint)
                        .padding(.top, 2)
                }
                .padding(.top, 7)
                .padding(.bottom, 7)
                .padding(.leading, 28)
                .padding(.trailing, 14)

            }
            .background(isHovered ? GitPulseColors.rowHover : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private var statusColor: Color {
        switch pullRequest.checkStatus {
        case .passing: return GitPulseColors.green
        case .failing: return GitPulseColors.red
        case .pending, .expected: return GitPulseColors.amber
        case .unknown: return GitPulseColors.textFaint
        }
    }

    private var badgeTone: BadgeTone {
        switch attentionState {
        case .ready, .checksPassing:
            return .green
        case .checksFailed, .changesRequested:
            return .red
        case .waitingForChecks:
            return .amber
        case .waitingForApproval:
            return .blue
        case .unknown:
            return .gray
        }
    }

    private var attentionState: PullRequestAttentionState {
        PullRequestAttentionState.from(
            checkStatus: pullRequest.checkStatus,
            reviewStatus: pullRequest.reviewStatus
        )
    }

    private var relativeTime: String {
        let seconds = max(0, Int(Date().timeIntervalSince(pullRequest.updatedAt)))
        if seconds < 60 {
            return "\(seconds)s"
        }
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        let hours = minutes / 60
        if hours < 24 {
            return "\(hours)h"
        }
        return "\(hours / 24)d"
    }
}
