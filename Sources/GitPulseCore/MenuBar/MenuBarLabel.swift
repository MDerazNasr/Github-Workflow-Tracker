import SwiftData
import SwiftUI

public struct MenuBarLabel: View {
    @Query private var settingsArr: [AppSettings]

    public init() {}

    private var settings: AppSettings? {
        settingsArr.first
    }

    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            if settings?.showCountInMenuBar == true && settings?.hideCountWhenZero != true {
                Text("0")
            }
        }
    }

    private var systemImage: String {
        switch settings?.menuBarIconStyle {
        case "dot": return "circle.fill"
        case "text-gp": return "textformat"
        case "octocat": return "chevron.left.forwardslash.chevron.right"
        default: return "point.topleft.down.curvedto.point.bottomright.up"
        }
    }
}
