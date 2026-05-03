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

    static func visibleFilters(settings: AppSettings?) -> [FeedFilter] {
        var filters: [FeedFilter] = [.all]
        guard let settings else {
            return filters + [.prs]
        }

        if settings.tabPRsEnabled {
            filters.append(.prs)
        }
        if settings.tabIssuesEnabled {
            filters.append(.issues)
        }
        if settings.tabCICDEnabled {
            filters.append(.cicd)
        }
        if settings.tabMentionsEnabled {
            filters.append(.mentions)
        }
        return filters
    }

    func isEnabled(in settings: AppSettings?) -> Bool {
        guard let settings else {
            return self == .all || self == .prs
        }

        switch self {
        case .all:
            return true
        case .prs:
            return settings.tabPRsEnabled
        case .issues:
            return settings.tabIssuesEnabled
        case .cicd:
            return settings.tabCICDEnabled
        case .mentions:
            return settings.tabMentionsEnabled
        }
    }
}
