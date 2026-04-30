import SwiftUI

enum GitPulseText {
    static func mono(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct SectionLabel: View {
    let text: String
    var isFirst = false

    var body: some View {
        Text(text.uppercased())
            .font(GitPulseText.mono(10))
            .kerning(1.2)
            .foregroundColor(GitPulseColors.textFaint)
            .padding(.top, isFirst ? 0 : 20)
            .padding(.bottom, 6)
            .padding(.horizontal, 14)
    }
}

struct SettingsHint: View {
    let text: String

    var body: some View {
        Text(text)
            .font(GitPulseText.mono(11))
            .foregroundColor(GitPulseColors.textMuted)
            .lineSpacing(4)
            .padding(.top, 6)
            .padding(.bottom, 10)
            .padding(.horizontal, 14)
    }
}
