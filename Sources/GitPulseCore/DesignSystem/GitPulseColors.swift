import SwiftUI

enum GitPulseColors {
    static let background = Color(hex: 0x111113)
    static let border = Color.white.opacity(0.09)
    static let divider = Color.white.opacity(0.05)
    static let dividerStrong = Color.white.opacity(0.07)
    static let hoverBorder = Color.white.opacity(0.21)
    static let rowHover = Color.white.opacity(0.03)
    static let selected = Color.white.opacity(0.07)
    static let groupBackground = Color.white.opacity(0.03)
    static let controlBackground = Color.white.opacity(0.05)

    static let textPrimary = Color.white.opacity(0.80)
    static let textRow = Color.white.opacity(0.67)
    static let textSecondary = Color.white.opacity(0.38)
    static let textMuted = Color.white.opacity(0.27)
    static let textFaint = Color.white.opacity(0.19)
    static let textGhost = Color.white.opacity(0.12)

    static let red = Color(hex: 0xf85149)
    static let amber = Color(hex: 0xd29922)
    static let green = Color(hex: 0x3fb950)
    static let blue = Color(hex: 0x79b8ff)
    static let blueBase = Color(hex: 0x388bfd)

    static let redFill = Color(hex: 0xf85149).opacity(0.13)
    static let redBorder = Color(hex: 0xf85149).opacity(0.27)
    static let amberFill = Color(hex: 0xd29922).opacity(0.13)
    static let amberBorder = Color(hex: 0xd29922).opacity(0.27)
    static let greenFill = Color(hex: 0x3fb950).opacity(0.13)
    static let greenBorder = Color(hex: 0x3fb950).opacity(0.27)
    static let blueFill = Color(hex: 0x388bfd).opacity(0.13)
    static let blueBorder = Color(hex: 0x388bfd).opacity(0.27)
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double(hex & 0xff) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
