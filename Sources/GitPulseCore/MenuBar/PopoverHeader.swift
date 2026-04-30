import SwiftUI

struct PopoverHeader: View {
    let isRefreshing: Bool
    let markAllRead: () -> Void
    let refresh: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("activity")
                    .font(GitPulseText.mono(10))
                    .kerning(0.8)
                    .foregroundColor(GitPulseColors.textFaint)
                Spacer()
                Button("mark all read", action: markAllRead)
                    .font(GitPulseText.mono(11))
                    .foregroundColor(GitPulseColors.textSecondary)
                    .buttonStyle(.plain)
                Button("⟳", action: refresh)
                    .font(GitPulseText.mono(11))
                    .foregroundColor(GitPulseColors.textSecondary)
                    .buttonStyle(.plain)
                    .disabled(isRefreshing)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 0.5)
        }
    }
}
