import Foundation

public struct GitHubUser: Codable, Equatable, Sendable {
    public let login: String
    public let name: String?
    public let avatarURL: URL?
    public let htmlURL: URL

    public init(login: String, name: String?, avatarURL: URL?, htmlURL: URL) {
        self.login = login
        self.name = name
        self.avatarURL = avatarURL
        self.htmlURL = htmlURL
    }

    enum CodingKeys: String, CodingKey {
        case login
        case name
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

public enum GitHubAccountStatus: Equatable, Sendable {
    case disconnected
    case connecting
    case connected(GitHubUser)
    case failed(String)

    public var displayText: String {
        switch self {
        case .disconnected:
            return "Not connected"
        case .connecting:
            return "Connecting"
        case .connected(let user):
            return user.name ?? user.login
        case .failed:
            return "Connection failed"
        }
    }

    public var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }
}

public enum GitHubAccountError: Error, Equatable, LocalizedError, Sendable {
    case emptyToken
    case unauthorized
    case invalidResponse
    case requestFailed(String)
    case storageFailed(String)

    public var errorDescription: String? {
        switch self {
        case .emptyToken:
            return "Enter a GitHub token."
        case .unauthorized:
            return "GitHub rejected this token."
        case .invalidResponse:
            return "GitHub returned an unreadable response."
        case .requestFailed(let message):
            return message
        case .storageFailed(let message):
            return message
        }
    }
}
