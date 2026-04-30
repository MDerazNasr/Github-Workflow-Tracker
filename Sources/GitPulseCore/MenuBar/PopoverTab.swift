import Foundation

enum PopoverTab: String, CaseIterable, Identifiable {
    case activity
    case settings

    var id: String { rawValue }

    var label: String {
        switch self {
        case .activity: return "Activity"
        case .settings: return "Settings"
        }
    }
}
