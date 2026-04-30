import Foundation
import SwiftData
import Testing
@testable import GitPulseCore

@MainActor
@Suite("Pull request sync service")
struct PullRequestSyncServiceTests {
    @Test("refresh inserts authored pull requests")
    func refreshInsertsPullRequests() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        let account = GitHubAccountService(
            tokenStore: TestTokenStore(initialToken: "token"),
            api: TestGitHubAPI()
        )
        let service = PullRequestSyncService(
            context: context,
            account: account,
            api: TestGitHubAPI(pullRequests: [.one])
        )

        await service.refreshAuthoredPullRequests()

        let stored = try context.fetch(FetchDescriptor<AuthoredPullRequest>())
        #expect(stored.count == 1)
        #expect(stored.first?.title == "Add dashboard")
        #expect(stored.first?.checkStatus == .passing)
    }

    @Test("refresh updates existing rows and removes stale rows")
    func refreshUpdatesAndRemovesStaleRows() async throws {
        let container = try makeContainer()
        let context = container.mainContext
        context.insert(AuthoredPullRequest(summary: .one, fetchedAt: Date()))
        context.insert(AuthoredPullRequest(summary: .stale, fetchedAt: Date()))
        try context.save()
        let account = GitHubAccountService(
            tokenStore: TestTokenStore(initialToken: "token"),
            api: TestGitHubAPI()
        )
        let service = PullRequestSyncService(
            context: context,
            account: account,
            api: TestGitHubAPI(pullRequests: [.updated])
        )

        await service.refreshAuthoredPullRequests()

        let stored = try context.fetch(FetchDescriptor<AuthoredPullRequest>())
        #expect(stored.count == 1)
        #expect(stored.first?.githubID == "PR_one")
        #expect(stored.first?.title == "Add dashboard polish")
        #expect(stored.first?.checkStatus == .failing)
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            AppSettings.self,
            NotificationPrefs.self,
            AuthoredPullRequest.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

private final class TestTokenStore: GitHubTokenStore, @unchecked Sendable {
    private var token: String?

    init(initialToken: String?) {
        token = initialToken
    }

    func loadToken() throws -> String? {
        token
    }

    func saveToken(_ token: String) throws {
        self.token = token
    }

    func deleteToken() throws {
        token = nil
    }
}

private final class TestGitHubAPI: GitHubAPI, @unchecked Sendable {
    private let pullRequests: [GitHubPullRequestSummary]

    init(pullRequests: [GitHubPullRequestSummary] = []) {
        self.pullRequests = pullRequests
    }

    func currentUser(token: String) async throws -> GitHubUser {
        GitHubUser(
            login: "octocat",
            name: nil,
            avatarURL: nil,
            htmlURL: URL(string: "https://github.com/octocat")!
        )
    }

    func authoredOpenPullRequests(token: String, limit: Int) async throws -> [GitHubPullRequestSummary] {
        pullRequests
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

private extension GitHubPullRequestSummary {
    static let one = GitHubPullRequestSummary(
        githubID: "PR_one",
        repositoryName: "octocat/hello-world",
        number: 12,
        title: "Add dashboard",
        url: URL(string: "https://github.com/octocat/hello-world/pull/12")!,
        authorLogin: "octocat",
        branchName: "dashboard",
        checkStatus: .passing,
        reviewStatus: .reviewRequired,
        mergeableRaw: "MERGEABLE",
        updatedAt: Date(timeIntervalSince1970: 1_000)
    )

    static let updated = GitHubPullRequestSummary(
        githubID: "PR_one",
        repositoryName: "octocat/hello-world",
        number: 12,
        title: "Add dashboard polish",
        url: URL(string: "https://github.com/octocat/hello-world/pull/12")!,
        authorLogin: "octocat",
        branchName: "dashboard",
        checkStatus: .failing,
        reviewStatus: .changesRequested,
        mergeableRaw: "CONFLICTING",
        updatedAt: Date(timeIntervalSince1970: 2_000)
    )

    static let stale = GitHubPullRequestSummary(
        githubID: "PR_stale",
        repositoryName: "octocat/old",
        number: 2,
        title: "Old PR",
        url: URL(string: "https://github.com/octocat/old/pull/2")!,
        authorLogin: "octocat",
        branchName: "old",
        checkStatus: .unknown,
        reviewStatus: .unknown,
        mergeableRaw: "UNKNOWN",
        updatedAt: Date(timeIntervalSince1970: 500)
    )
}
