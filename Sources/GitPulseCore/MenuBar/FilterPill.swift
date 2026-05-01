import SwiftUI

struct FilterPill: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(GitPulseText.mono(10))
                .foregroundColor(isActive ? GitPulseColors.textPrimary : GitPulseColors.mutedBadgeText)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(isActive ? GitPulseColors.selected : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isActive ? GitPulseColors.hoverBorder : GitPulseColors.controlStroke, lineWidth: 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}
