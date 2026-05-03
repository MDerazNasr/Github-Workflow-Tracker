import SwiftUI

struct DemoWorkflowEventRow: View {
    let event: DemoWorkflowEvent
    @State private var isHovered = false

    var body: some View {
        Link(destination: event.url) {
            HStack(alignment: .top, spacing: 10) {
                StatusDot(color: event.statusColor, size: 5)
                    .padding(.top, 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(event.title)
                        .font(GitPulseText.mono(12))
                        .foregroundColor(GitPulseColors.textPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    HStack(spacing: 8) {
                        Text("@\(event.actor)")
                            .font(GitPulseText.mono(10))
                            .foregroundColor(GitPulseColors.textMuted)
                        CountBadge(text: event.statusLabel, tone: event.badgeTone)
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
            .background(isHovered ? GitPulseColors.rowHover : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private var relativeTime: String {
        let seconds = max(0, Int(Date().timeIntervalSince(event.updatedAt)))
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
