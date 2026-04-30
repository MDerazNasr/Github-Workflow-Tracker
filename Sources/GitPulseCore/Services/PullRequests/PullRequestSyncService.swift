import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class PullRequestSyncService {
    public private(set) var isRefreshing = false
    public private(set) var lastErrorMessage: String?

    private let context: ModelContext
    private let account: GitHubAccountService
    private let api: GitHubAPI

    public init(
        context: ModelContext,
        account: GitHubAccountService,
        api: GitHubAPI = URLSessionGitHubAPI()
    ) {
        self.context = context
        self.account = account
        self.api = api
    }

    public func refreshAuthoredPullRequests(limit: Int = 20) async {
        guard !isRefreshing else {
            return
        }

        isRefreshing = true
        lastErrorMessage = nil

        do {
            guard let token = try account.storedToken() else {
                throw GitHubAccountError.emptyToken
            }

            let summaries = try await api.authoredOpenPullRequests(token: token, limit: limit)
            try upsert(summaries)
        } catch {
            lastErrorMessage = displayMessage(for: error)
        }

        isRefreshing = false
    }

    private func upsert(_ summaries: [GitHubPullRequestSummary]) throws {
        let existing = try context.fetch(FetchDescriptor<AuthoredPullRequest>())
        let existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.githubID, $0) })
        let incomingIDs = Set(summaries.map(\.githubID))
        let now = Date()

        for summary in summaries {
            if let stored = existingByID[summary.githubID] {
                update(stored, with: summary, fetchedAt: now)
            } else {
                context.insert(AuthoredPullRequest(summary: summary, fetchedAt: now))
            }
        }

        for stored in existing where !incomingIDs.contains(stored.githubID) {
            context.delete(stored)
        }

        try context.save()
    }

    private func update(
        _ stored: AuthoredPullRequest,
        with summary: GitHubPullRequestSummary,
        fetchedAt: Date
    ) {
        stored.repositoryName = summary.repositoryName
        stored.number = summary.number
        stored.title = summary.title
        stored.url = summary.url
        stored.authorLogin = summary.authorLogin
        stored.branchName = summary.branchName
        stored.checkStatus = summary.checkStatus
        stored.reviewStatus = summary.reviewStatus
        stored.mergeableRaw = summary.mergeableRaw
        stored.updatedAt = summary.updatedAt
        stored.fetchedAt = fetchedAt
    }

    private func displayMessage(for error: Error) -> String {
        if let accountError = error as? GitHubAccountError {
            return accountError.localizedDescription
        }
        return error.localizedDescription
    }
}

private extension AuthoredPullRequest {
    convenience init(summary: GitHubPullRequestSummary, fetchedAt: Date) {
        self.init(
            githubID: summary.githubID,
            repositoryName: summary.repositoryName,
            number: summary.number,
            title: summary.title,
            url: summary.url,
            authorLogin: summary.authorLogin,
            branchName: summary.branchName,
            checkStatus: summary.checkStatus,
            reviewStatus: summary.reviewStatus,
            mergeableRaw: summary.mergeableRaw,
            updatedAt: summary.updatedAt,
            fetchedAt: fetchedAt
        )
    }
}
