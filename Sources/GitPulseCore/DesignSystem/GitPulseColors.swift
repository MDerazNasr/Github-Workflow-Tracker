import AppKit
import SwiftUI

enum GitPulseColors {
    static var background: Color { adaptive(light: 0xf6f8fa, dark: 0x111113) }
    static var border: Color { adaptive(light: 0xd0d7de, dark: 0xffffff, darkOpacity: 0.09) }
    static var divider: Color { adaptive(light: 0xd8dee4, dark: 0xffffff, lightOpacity: 0.80, darkOpacity: 0.05) }
    static var dividerStrong: Color { adaptive(light: 0xd0d7de, dark: 0xffffff, darkOpacity: 0.07) }
    static var hoverBorder: Color { adaptive(light: 0x8c959f, dark: 0xffffff, darkOpacity: 0.21) }
    static var rowHover: Color { adaptive(light: 0xeaeef2, dark: 0xffffff, darkOpacity: 0.03) }
    static var selected: Color { adaptive(light: 0xdbeafe, dark: 0xffffff, lightOpacity: 0.90, darkOpacity: 0.07) }
    static var groupBackground: Color { adaptive(light: 0xffffff, dark: 0xffffff, darkOpacity: 0.03) }
    static var controlBackground: Color { adaptive(light: 0xf6f8fa, dark: 0xffffff, darkOpacity: 0.05) }
    static var controlStroke: Color { adaptive(light: 0xd0d7de, dark: 0xffffff, darkOpacity: 0.12) }
    static var controlInactiveFill: Color { adaptive(light: 0xd8dee4, dark: 0xffffff, lightOpacity: 0.85, darkOpacity: 0.09) }
    static var controlInactiveKnob: Color { adaptive(light: 0x6e7781, dark: 0xffffff, darkOpacity: 0.56) }
    static var mutedBadgeText: Color { adaptive(light: 0x57606a, dark: 0xffffff, darkOpacity: 0.31) }
    static var mutedBadgeFill: Color { adaptive(light: 0xeaeef2, dark: 0xffffff, darkOpacity: 0.07) }
    static var subtleFill: Color { adaptive(light: 0xeaeef2, dark: 0xffffff, lightOpacity: 0.70, darkOpacity: 0.04) }

    static var textPrimary: Color { adaptive(light: 0x24292f, dark: 0xffffff, darkOpacity: 0.80) }
    static var textRow: Color { adaptive(light: 0x24292f, dark: 0xffffff, lightOpacity: 0.86, darkOpacity: 0.67) }
    static var textSecondary: Color { adaptive(light: 0x57606a, dark: 0xffffff, darkOpacity: 0.38) }
    static var textMuted: Color { adaptive(light: 0x6e7781, dark: 0xffffff, darkOpacity: 0.27) }
    static var textFaint: Color { adaptive(light: 0x8c959f, dark: 0xffffff, darkOpacity: 0.19) }
    static var textGhost: Color { adaptive(light: 0xafb8c1, dark: 0xffffff, darkOpacity: 0.12) }

    static var red: Color { adaptive(light: 0xcf222e, dark: 0xf85149) }
    static var amber: Color { adaptive(light: 0x9a6700, dark: 0xd29922) }
    static var green: Color { adaptive(light: 0x1a7f37, dark: 0x3fb950) }
    static var blue: Color { adaptive(light: 0x0969da, dark: 0x79b8ff) }
    static var blueBase: Color { adaptive(light: 0x0969da, dark: 0x388bfd) }

    static var redFill: Color { red.opacity(0.13) }
    static var redBorder: Color { red.opacity(0.27) }
    static var amberFill: Color { amber.opacity(0.13) }
    static var amberBorder: Color { amber.opacity(0.27) }
    static var greenFill: Color { green.opacity(0.13) }
    static var greenBorder: Color { green.opacity(0.27) }
    static var blueFill: Color { blueBase.opacity(0.13) }
    static var blueBorder: Color { blueBase.opacity(0.27) }

    static func backgroundNSColor(for appearance: AppAppearance) -> NSColor {
        switch appearance {
        case .light:
            return nsColor(hex: 0xf6f8fa)
        case .dark:
            return nsColor(hex: 0x111113)
        case .system:
            return dynamicNSColor(light: 0xf6f8fa, dark: 0x111113)
        }
    }

    private static func adaptive(
        light: UInt32,
        dark: UInt32,
        lightOpacity: CGFloat = 1,
        darkOpacity: CGFloat = 1
    ) -> Color {
        Color(nsColor: dynamicNSColor(
            light: light,
            dark: dark,
            lightOpacity: lightOpacity,
            darkOpacity: darkOpacity
        ))
    }

    private static func dynamicNSColor(
        light: UInt32,
        dark: UInt32,
        lightOpacity: CGFloat = 1,
        darkOpacity: CGFloat = 1
    ) -> NSColor {
        NSColor(name: nil) { appearance in
            let match = appearance.bestMatch(from: [.darkAqua, .aqua])
            if match == .darkAqua {
                return nsColor(hex: dark, opacity: darkOpacity)
            }
            return nsColor(hex: light, opacity: lightOpacity)
        }
    }

    private static func nsColor(hex: UInt32, opacity: CGFloat = 1) -> NSColor {
        NSColor(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: opacity
        )
    }
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double(hex & 0xff) / 255
        self.init(red: red, green: green, blue: blue)
    }
}
