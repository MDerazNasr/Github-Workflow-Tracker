import Foundation
import Observation

@MainActor
@Observable
public final class GitHubAccountService {
    public private(set) var status: GitHubAccountStatus = .disconnected
    public private(set) var errorMessage: String?

    private let tokenStore: GitHubTokenStore
    private let api: GitHubAPI

    public init(
        tokenStore: GitHubTokenStore = KeychainGitHubTokenStore(),
        api: GitHubAPI = URLSessionGitHubAPI()
    ) {
        self.tokenStore = tokenStore
        self.api = api
    }

    public func restoreSession() async {
        do {
            guard let token = try tokenStore.loadToken() else {
                status = .disconnected
                return
            }

            try await verifyAndStore(token: token, shouldSaveToken: false)
        } catch {
            status = .failed(displayMessage(for: error))
            errorMessage = displayMessage(for: error)
        }
    }

    public func connect(token rawToken: String) async {
        let token = rawToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else {
            status = .failed(GitHubAccountError.emptyToken.localizedDescription)
            errorMessage = GitHubAccountError.emptyToken.localizedDescription
            return
        }

        do {
            try await verifyAndStore(token: token, shouldSaveToken: true)
        } catch {
            status = .failed(displayMessage(for: error))
            errorMessage = displayMessage(for: error)
        }
    }

    public func signOut() {
        do {
            try tokenStore.deleteToken()
            status = .disconnected
            errorMessage = nil
        } catch {
            status = .failed(displayMessage(for: error))
            errorMessage = displayMessage(for: error)
        }
    }

    private func verifyAndStore(token: String, shouldSaveToken: Bool) async throws {
        status = .connecting
        errorMessage = nil

        let user = try await api.currentUser(token: token)
        if shouldSaveToken {
            try tokenStore.saveToken(token)
        }

        status = .connected(user)
    }

    private func displayMessage(for error: Error) -> String {
        if let accountError = error as? GitHubAccountError {
            return accountError.localizedDescription
        }
        return error.localizedDescription
    }
}
