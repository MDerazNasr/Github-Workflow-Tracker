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
                            CountBadge(text: pullRequest.checkStatus.displayName.lowercased(), tone: badgeTone)
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

                if pullRequest.checkStatus == .failing {
                    Circle()
                        .fill(GitPulseColors.red)
                        .frame(width: 6, height: 6)
                        .offset(x: 18, y: 9)
                }
            }
            .background(isHovered ? GitPulseColors.rowHover : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private var statusColor: Color {
        switch pullRequest.checkStatus {
        case .passing: return .green
        case .failing: return .red
        case .pending, .expected: return .orange
        case .unknown: return .secondary
        }
    }

    private var badgeTone: BadgeTone {
        switch pullRequest.checkStatus {
        case .passing: return .green
        case .failing: return .red
        case .pending, .expected: return .amber
        case .unknown: return .gray
        }
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
