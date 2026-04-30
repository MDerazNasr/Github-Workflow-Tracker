import Foundation

enum EventType: String, CaseIterable, Identifiable {
    case pullRequestReview = "pull-request-review"
    case pullRequestMerged = "pull-request-merged"
    case issueAssigned = "issue-assigned"
    case ciFailed = "ci-failed"
    case ciRecovered = "ci-recovered"
    case mention = "mention"

    var id: String { rawValue }

    static var allNotifiableCases: [EventType] {
        allCases
    }

    var displayName: String {
        switch self {
        case .pullRequestReview: return "PR review requested"
        case .pullRequestMerged: return "PR merged"
        case .issueAssigned: return "Issue assigned"
        case .ciFailed: return "CI failed"
        case .ciRecovered: return "CI recovered"
        case .mention: return "Mention"
        }
    }
}
