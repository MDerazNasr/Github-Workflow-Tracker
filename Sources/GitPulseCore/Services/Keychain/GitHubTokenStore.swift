import Foundation
import Security

public protocol GitHubTokenStore: Sendable {
    func loadToken() throws -> String?
    func saveToken(_ token: String) throws
    func deleteToken() throws
}

public struct KeychainGitHubTokenStore: GitHubTokenStore {
    private let service: String
    private let account: String

    public init(
        service: String = "com.gitpulse.github",
        account: String = "github-token"
    ) {
        self.service = service
        self.account = account
    }

    public func loadToken() throws -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw error(status)
        }

        guard
            let data = item as? Data,
            let token = String(data: data, encoding: .utf8)
        else {
            throw GitHubAccountError.storageFailed("Stored GitHub token is unreadable.")
        }

        return token
    }

    public func saveToken(_ token: String) throws {
        guard let data = token.data(using: .utf8) else {
            throw GitHubAccountError.storageFailed("GitHub token could not be encoded.")
        }

        try deleteToken()

        var item = baseQuery()
        item[kSecValueData as String] = data

        let status = SecItemAdd(item as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw error(status)
        }
    }

    public func deleteToken() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        if status == errSecItemNotFound {
            return
        }
        guard status == errSecSuccess else {
            throw error(status)
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    private func error(_ status: OSStatus) -> GitHubAccountError {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? "Keychain error \(status)."
        return .storageFailed(message)
    }
}
