import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class AppState {
    public let container: ModelContainer
    public let gitHubAccount: GitHubAccountService
    public var lastPollDate: Date?
    public var rateLimitSummary: String

    public init(inMemory: Bool = false) {
        gitHubAccount = GitHubAccountService()

        let schema = Schema([
            AppSettings.self,
            NotificationPrefs.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create GitPulse model container: \(error)")
        }

        AppSettings.ensureExists(in: container.mainContext)
        NotificationPrefs.ensureDefaults(in: container.mainContext)
        lastPollDate = nil
        rateLimitSummary = "Not checked"

        Task {
            await gitHubAccount.restoreSession()
        }
    }
}
