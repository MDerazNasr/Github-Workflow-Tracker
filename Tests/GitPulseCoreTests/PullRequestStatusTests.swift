import Testing
@testable import GitPulseCore

@Suite("Pull request status mapping")
struct PullRequestStatusTests {
    @Test("check status maps GitHub rollup states")
    func checkStatusMapsRollupStates() {
        #expect(PullRequestCheckStatus.fromGraphQLState("SUCCESS") == .passing)
        #expect(PullRequestCheckStatus.fromGraphQLState("FAILURE") == .failing)
        #expect(PullRequestCheckStatus.fromGraphQLState("ERROR") == .failing)
        #expect(PullRequestCheckStatus.fromGraphQLState("PENDING") == .pending)
        #expect(PullRequestCheckStatus.fromGraphQLState("EXPECTED") == .expected)
        #expect(PullRequestCheckStatus.fromGraphQLState(nil) == .unknown)
    }

    @Test("review status maps GitHub review decisions")
    func reviewStatusMapsDecisions() {
        #expect(PullRequestReviewStatus.fromGraphQLDecision("APPROVED") == .approved)
        #expect(PullRequestReviewStatus.fromGraphQLDecision("CHANGES_REQUESTED") == .changesRequested)
        #expect(PullRequestReviewStatus.fromGraphQLDecision("REVIEW_REQUIRED") == .reviewRequired)
        #expect(PullRequestReviewStatus.fromGraphQLDecision(nil) == .unknown)
    }

    @Test("attention state describes passive waiting states")
    func attentionStateDescribesPassiveWaitingStates() {
        #expect(PullRequestAttentionState.from(checkStatus: .pending, reviewStatus: .reviewRequired) == .waitingForChecks)
        #expect(PullRequestAttentionState.from(checkStatus: .expected, reviewStatus: .approved) == .waitingForChecks)
        #expect(PullRequestAttentionState.from(checkStatus: .passing, reviewStatus: .reviewRequired) == .waitingForApproval)
    }

    @Test("attention state prioritizes states that need action")
    func attentionStatePrioritizesActionableStates() {
        #expect(PullRequestAttentionState.from(checkStatus: .passing, reviewStatus: .changesRequested) == .changesRequested)
        #expect(PullRequestAttentionState.from(checkStatus: .failing, reviewStatus: .approved) == .checksFailed)
        #expect(PullRequestAttentionState.from(checkStatus: .passing, reviewStatus: .approved) == .ready)
    }
}
