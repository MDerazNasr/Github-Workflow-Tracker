import Foundation

public enum PullRequestCheckStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case passing
    case failing
    case pending
    case expected
    case unknown

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .passing: return "Passing"
        case .failing: return "Failing"
        case .pending: return "Pending"
        case .expected: return "Expected"
        case .unknown: return "Unknown"
        }
    }

    public var systemImage: String {
        switch self {
        case .passing: return "checkmark.circle.fill"
        case .failing: return "xmark.circle.fill"
        case .pending: return "clock.fill"
        case .expected: return "hourglass"
        case .unknown: return "questionmark.circle"
        }
    }

    public static func fromGraphQLState(_ state: String?) -> PullRequestCheckStatus {
        switch state {
        case "SUCCESS": return .passing
        case "FAILURE", "ERROR": return .failing
        case "PENDING": return .pending
        case "EXPECTED": return .expected
        default: return .unknown
        }
    }
}

public enum PullRequestReviewStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case approved
    case changesRequested
    case reviewRequired
    case unknown

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .approved: return "Approved"
        case .changesRequested: return "Changes requested"
        case .reviewRequired: return "Review required"
        case .unknown: return "Review unknown"
        }
    }

    public static func fromGraphQLDecision(_ decision: String?) -> PullRequestReviewStatus {
        switch decision {
        case "APPROVED": return .approved
        case "CHANGES_REQUESTED": return .changesRequested
        case "REVIEW_REQUIRED": return .reviewRequired
        default: return .unknown
        }
    }
}

public enum PullRequestAttentionState: String, Codable, CaseIterable, Identifiable, Sendable {
    case waitingForChecks
    case waitingForApproval
    case changesRequested
    case checksFailed
    case ready
    case checksPassing
    case unknown

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .waitingForChecks: return "Waiting for checks"
        case .waitingForApproval: return "Waiting for approval"
        case .changesRequested: return "Changes requested"
        case .checksFailed: return "Checks failed"
        case .ready: return "Ready"
        case .checksPassing: return "Checks passing"
        case .unknown: return "Status unknown"
        }
    }

    public static func from(
        checkStatus: PullRequestCheckStatus,
        reviewStatus: PullRequestReviewStatus
    ) -> PullRequestAttentionState {
        if reviewStatus == .changesRequested {
            return .changesRequested
        }

        switch checkStatus {
        case .failing:
            return .checksFailed
        case .pending, .expected:
            return .waitingForChecks
        case .passing:
            switch reviewStatus {
            case .reviewRequired:
                return .waitingForApproval
            case .approved:
                return .ready
            case .unknown:
                return .checksPassing
            case .changesRequested:
                return .changesRequested
            }
        case .unknown:
            if reviewStatus == .reviewRequired {
                return .waitingForApproval
            }
            return .unknown
        }
    }
}
