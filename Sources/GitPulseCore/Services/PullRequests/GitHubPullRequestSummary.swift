import Foundation

public struct GitHubPullRequestSummary: Equatable, Sendable {
    public let githubID: String
    public let repositoryName: String
    public let number: Int
    public let title: String
    public let url: URL
    public let authorLogin: String
    public let branchName: String
    public let checkStatus: PullRequestCheckStatus
    public let reviewStatus: PullRequestReviewStatus
    public let mergeableRaw: String
    public let updatedAt: Date

    public init(
        githubID: String,
        repositoryName: String,
        number: Int,
        title: String,
        url: URL,
        authorLogin: String,
        branchName: String,
        checkStatus: PullRequestCheckStatus,
        reviewStatus: PullRequestReviewStatus,
        mergeableRaw: String,
        updatedAt: Date
    ) {
        self.githubID = githubID
        self.repositoryName = repositoryName
        self.number = number
        self.title = title
        self.url = url
        self.authorLogin = authorLogin
        self.branchName = branchName
        self.checkStatus = checkStatus
        self.reviewStatus = reviewStatus
        self.mergeableRaw = mergeableRaw
        self.updatedAt = updatedAt
    }
}
