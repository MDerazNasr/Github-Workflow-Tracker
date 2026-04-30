import Foundation
import Testing
@testable import GitPulseCore

@MainActor
@Suite("GitHub account service")
struct GitHubAccountServiceTests {
    @Test("connect verifies token and stores it")
    func connectStoresVerifiedToken() async {
        let store = MemoryTokenStore()
        let api = StubGitHubAPI(result: .success(.fixture))
        let service = GitHubAccountService(tokenStore: store, api: api)

        await service.connect(token: "  ghp_valid  ")

        #expect(service.status == .connected(.fixture))
        #expect(store.savedToken == "ghp_valid")
    }

    @Test("connect rejects empty token without calling GitHub")
    func connectRejectsEmptyToken() async {
        let store = MemoryTokenStore()
        let api = StubGitHubAPI(result: .success(.fixture))
        let service = GitHubAccountService(tokenStore: store, api: api)

        await service.connect(token: "   ")

        #expect(service.status == .failed("Enter a GitHub token."))
        #expect(api.requestedTokens.isEmpty)
    }

    @Test("restore verifies stored token")
    func restoreVerifiesStoredToken() async {
        let store = MemoryTokenStore(initialToken: "stored-token")
        let api = StubGitHubAPI(result: .success(.fixture))
        let service = GitHubAccountService(tokenStore: store, api: api)

        await service.restoreSession()

        #expect(service.status == .connected(.fixture))
        #expect(api.requestedTokens == ["stored-token"])
    }

    @Test("sign out deletes token and disconnects account")
    func signOutDeletesToken() async {
        let store = MemoryTokenStore(initialToken: "stored-token")
        let api = StubGitHubAPI(result: .success(.fixture))
        let service = GitHubAccountService(tokenStore: store, api: api)

        await service.restoreSession()
        service.signOut()

        #expect(service.status == .disconnected)
        #expect(store.deleted)
    }
}

private final class MemoryTokenStore: GitHubTokenStore, @unchecked Sendable {
    var savedToken: String?
    var deleted = false
    private var token: String?

    init(initialToken: String? = nil) {
        token = initialToken
    }

    func loadToken() throws -> String? {
        token
    }

    func saveToken(_ token: String) throws {
        savedToken = token
        self.token = token
    }

    func deleteToken() throws {
        deleted = true
        token = nil
    }
}

private final class StubGitHubAPI: GitHubAPI, @unchecked Sendable {
    var requestedTokens: [String] = []
    private let result: Result<GitHubUser, Error>

    init(result: Result<GitHubUser, Error>) {
        self.result = result
    }

    func currentUser(token: String) async throws -> GitHubUser {
        requestedTokens.append(token)
        return try result.get()
    }

    func authoredOpenPullRequests(token: String, limit: Int) async throws -> [GitHubPullRequestSummary] {
        []
    }
}

private extension GitHubUser {
    static let fixture = GitHubUser(
        login: "octocat",
        name: "The Octocat",
        avatarURL: URL(string: "https://github.com/images/error/octocat_happy.gif"),
        htmlURL: URL(string: "https://github.com/octocat")!
    )
}
