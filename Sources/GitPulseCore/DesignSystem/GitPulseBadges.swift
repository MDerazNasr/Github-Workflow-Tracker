import SwiftUI

enum BadgeTone {
    case red
    case amber
    case green
    case blue
    case gray

    var foreground: Color {
        switch self {
        case .red: return GitPulseColors.red
        case .amber: return GitPulseColors.amber
        case .green: return GitPulseColors.green
        case .blue: return GitPulseColors.blue
        case .gray: return Color.white.opacity(0.31)
        }
    }

    var background: Color {
        switch self {
        case .red: return GitPulseColors.redFill
        case .amber: return GitPulseColors.amberFill
        case .green: return GitPulseColors.greenFill
        case .blue: return GitPulseColors.blueFill
        case .gray: return Color.white.opacity(0.07)
        }
    }

    var border: Color {
        switch self {
        case .red: return GitPulseColors.redBorder
        case .amber: return GitPulseColors.amberBorder
        case .green: return GitPulseColors.greenBorder
        case .blue: return GitPulseColors.blueBorder
        case .gray: return Color.white.opacity(0.12)
        }
    }
}

struct CountBadge: View {
    let text: String
    let tone: BadgeTone

    var body: some View {
        Text(text)
            .font(GitPulseText.mono(10))
            .foregroundColor(tone.foreground)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(tone.background)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(tone.border, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct StatusDot: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}
