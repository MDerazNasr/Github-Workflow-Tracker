import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol GitHubAPI: Sendable {
    func currentUser(token: String) async throws -> GitHubUser
}

public struct URLSessionGitHubAPI: GitHubAPI {
    private let session: URLSession
    private let baseURL: URL

    public init(
        session: URLSession = .shared,
        baseURL: URL = URL(string: "https://api.github.com")!
    ) {
        self.session = session
        self.baseURL = baseURL
    }

    public func currentUser(token: String) async throws -> GitHubUser {
        var request = URLRequest(url: baseURL.appending(path: "user"))
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("GitPulse", forHTTPHeaderField: "User-Agent")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GitHubAccountError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                do {
                    return try JSONDecoder().decode(GitHubUser.self, from: data)
                } catch {
                    throw GitHubAccountError.invalidResponse
                }
            case 401, 403:
                throw GitHubAccountError.unauthorized
            default:
                throw GitHubAccountError.requestFailed("GitHub returned HTTP \(httpResponse.statusCode).")
            }
        } catch let error as GitHubAccountError {
            throw error
        } catch {
            throw GitHubAccountError.requestFailed(error.localizedDescription)
        }
    }
}
