import SwiftUI

struct PopoverFooter: View {
    let appVersion: String
    let openSettings: () -> Void
    let openGitHub: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 0.5)

            HStack {
                Button("settings ↗", action: openSettings)
                    .font(GitPulseText.mono(11))
                    .foregroundColor(GitPulseColors.textSecondary)
                    .buttonStyle(.plain)
                Spacer()
                Text(appVersion)
                    .font(GitPulseText.mono(10))
                    .foregroundColor(GitPulseColors.textGhost)
                Spacer()
                Button("open github", action: openGitHub)
                    .font(GitPulseText.mono(11))
                    .foregroundColor(GitPulseColors.textSecondary)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
    }
}
