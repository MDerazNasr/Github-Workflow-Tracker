import SwiftUI

struct SettingsGroup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(GitPulseColors.groupBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(GitPulseColors.border, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 14)
    }
}

struct SettingsRow<Control: View>: View {
    let label: String
    var subtitle: String?
    var hasDivider = true
    @ViewBuilder let control: Control

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(GitPulseText.mono(12))
                        .foregroundColor(GitPulseColors.textRow)
                    if let subtitle {
                        Text(subtitle)
                            .font(GitPulseText.mono(10))
                            .foregroundColor(GitPulseColors.textSecondary)
                    }
                }
                Spacer(minLength: 12)
                control
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minHeight: 44)

            if hasDivider {
                Rectangle()
                    .fill(GitPulseColors.dividerStrong)
                    .frame(height: 0.5)
                    .padding(.leading, 14)
            }
        }
    }
}

struct DarkToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Capsule()
                .fill(isOn ? GitPulseColors.green.opacity(0.53) : GitPulseColors.controlInactiveFill)
                .frame(width: 30, height: 17)
                .overlay(
                    Circle()
                        .fill(isOn ? GitPulseColors.green : GitPulseColors.controlInactiveKnob)
                        .frame(width: 12, height: 12)
                        .offset(x: isOn ? 6.5 : -6.5)
                        .animation(.spring(duration: 0.2), value: isOn)
                )
        }
        .buttonStyle(.plain)
    }
}

struct MiniToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Capsule()
                .fill(isOn ? GitPulseColors.blueBase.opacity(0.33) : GitPulseColors.controlInactiveFill)
                .frame(width: 22, height: 13)
                .overlay(
                    Circle()
                        .fill(isOn ? GitPulseColors.blue : GitPulseColors.controlInactiveKnob)
                        .frame(width: 9, height: 9)
                        .offset(x: isOn ? 4.5 : -4.5)
                        .animation(.spring(duration: 0.2), value: isOn)
                )
        }
        .buttonStyle(.plain)
    }
}

struct StandardButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GitPulseText.mono(11))
                .foregroundColor(GitPulseColors.textRow)
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background(GitPulseColors.controlBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(GitPulseColors.controlStroke, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

struct DangerButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GitPulseText.mono(11))
                .foregroundColor(GitPulseColors.red)
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .background(GitPulseColors.red.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(GitPulseColors.red.opacity(0.19), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

struct KbdBadge: View {
    let shortcut: String

    var body: some View {
        Text(shortcut)
            .font(GitPulseText.mono(11))
            .foregroundColor(GitPulseColors.mutedBadgeText)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(GitPulseColors.controlBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(GitPulseColors.controlStroke, lineWidth: 0.5)
            )
    }
}
