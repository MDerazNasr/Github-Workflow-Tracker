import Foundation

enum FeedFilter: String, CaseIterable, Identifiable {
    case all
    case prs
    case issues
    case cicd
    case mentions

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "all"
        case .prs: return "prs"
        case .issues: return "issues"
        case .cicd: return "ci/cd"
        case .mentions: return "mentions"
        }
    }
}
