import Foundation
import SwiftData

@Model
final class AuthoredPullRequest {
    @Attribute(.unique) var githubID: String
    var repositoryName: String
    var number: Int
    var title: String
    var url: URL
    var authorLogin: String
    var branchName: String
    var checkStatusRaw: String
    var reviewStatusRaw: String
    var mergeableRaw: String
    var updatedAt: Date
    var fetchedAt: Date

    init(
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
        updatedAt: Date,
        fetchedAt: Date = Date()
    ) {
        self.githubID = githubID
        self.repositoryName = repositoryName
        self.number = number
        self.title = title
        self.url = url
        self.authorLogin = authorLogin
        self.branchName = branchName
        self.checkStatusRaw = checkStatus.rawValue
        self.reviewStatusRaw = reviewStatus.rawValue
        self.mergeableRaw = mergeableRaw
        self.updatedAt = updatedAt
        self.fetchedAt = fetchedAt
    }

    var checkStatus: PullRequestCheckStatus {
        get { PullRequestCheckStatus(rawValue: checkStatusRaw) ?? .unknown }
        set { checkStatusRaw = newValue.rawValue }
    }

    var reviewStatus: PullRequestReviewStatus {
        get { PullRequestReviewStatus(rawValue: reviewStatusRaw) ?? .unknown }
        set { reviewStatusRaw = newValue.rawValue }
    }
}
