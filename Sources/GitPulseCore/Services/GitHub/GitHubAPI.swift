import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol GitHubAPI: Sendable {
    func currentUser(token: String) async throws -> GitHubUser
    func authoredOpenPullRequests(token: String, limit: Int) async throws -> [GitHubPullRequestSummary]
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

    public func authoredOpenPullRequests(token: String, limit: Int = 20) async throws -> [GitHubPullRequestSummary] {
        var request = URLRequest(url: URL(string: "https://api.github.com/graphql")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("GitPulse", forHTTPHeaderField: "User-Agent")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GraphQLRequest(
            query: Self.authoredPullRequestsQuery,
            variables: ["limit": max(1, min(limit, 50))]
        )
        request.httpBody = try JSONEncoder().encode(body)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw GitHubAccountError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200:
                let response = try JSONDecoder.gitHub.decode(GraphQLResponse.self, from: data)
                if let errors = response.errors, let first = errors.first {
                    throw GitHubAccountError.requestFailed(first.message)
                }
                guard let data = response.data else {
                    throw GitHubAccountError.invalidResponse
                }
                return data.viewer.pullRequests.nodes.map(\.summary)
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

    private static let authoredPullRequestsQuery = """
    query AuthoredOpenPullRequests($limit: Int!) {
      viewer {
        pullRequests(first: $limit, states: OPEN, orderBy: {field: UPDATED_AT, direction: DESC}) {
          nodes {
            id
            number
            title
            url
            updatedAt
            headRefName
            reviewDecision
            mergeable
            author {
              login
            }
            repository {
              nameWithOwner
            }
            commits(last: 1) {
              nodes {
                commit {
                  statusCheckRollup {
                    state
                  }
                }
              }
            }
          }
        }
      }
    }
    """
}

private struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: Int]
}

private struct GraphQLResponse: Decodable {
    let data: GraphQLData?
    let errors: [GraphQLError]?
}

private struct GraphQLError: Decodable {
    let message: String
}

private struct GraphQLData: Decodable {
    let viewer: Viewer
}

private struct Viewer: Decodable {
    let pullRequests: PullRequestConnection
}

private struct PullRequestConnection: Decodable {
    let nodes: [PullRequestNode]
}

private struct PullRequestNode: Decodable {
    let id: String
    let number: Int
    let title: String
    let url: URL
    let updatedAt: Date
    let headRefName: String?
    let reviewDecision: String?
    let mergeable: String?
    let author: Author?
    let repository: Repository
    let commits: CommitConnection

    var summary: GitHubPullRequestSummary {
        GitHubPullRequestSummary(
            githubID: id,
            repositoryName: repository.nameWithOwner,
            number: number,
            title: title,
            url: url,
            authorLogin: author?.login ?? "unknown",
            branchName: headRefName ?? "",
            checkStatus: PullRequestCheckStatus.fromGraphQLState(commits.latestStatusState),
            reviewStatus: PullRequestReviewStatus.fromGraphQLDecision(reviewDecision),
            mergeableRaw: mergeable ?? "UNKNOWN",
            updatedAt: updatedAt
        )
    }
}

private struct Author: Decodable {
    let login: String
}

private struct Repository: Decodable {
    let nameWithOwner: String
}

private struct CommitConnection: Decodable {
    let nodes: [CommitNode]

    var latestStatusState: String? {
        nodes.last?.commit.statusCheckRollup?.state
    }
}

private struct CommitNode: Decodable {
    let commit: Commit
}

private struct Commit: Decodable {
    let statusCheckRollup: StatusCheckRollup?
}

private struct StatusCheckRollup: Decodable {
    let state: String
}

private extension JSONDecoder {
    static var gitHub: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
