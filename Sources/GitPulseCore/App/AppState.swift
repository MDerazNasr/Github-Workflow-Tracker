import AppKit
import Foundation
import Observation
import SwiftData

@MainActor
@Observable
public final class AppState {
    public let container: ModelContainer
    public let gitHubAccount: GitHubAccountService
    public let pullRequestSync: PullRequestSyncService
    public private(set) var globalShortcuts: GlobalShortcutService?
    public private(set) var quickPopover: QuickPopoverWindowController?
    public var lastPollDate: Date?
    public var lastMarkedAllReadDate: Date?
    public var rateLimitSummary: String

    public init(inMemory: Bool = false, enableGlobalShortcuts: Bool = true) {
        gitHubAccount = GitHubAccountService()

        let schema = Schema([
            AppSettings.self,
            NotificationPrefs.self,
            AuthoredPullRequest.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create GitPulse model container: \(error)")
        }

        AppSettings.ensureExists(in: container.mainContext)
        NotificationPrefs.ensureDefaults(in: container.mainContext)
        pullRequestSync = PullRequestSyncService(
            context: container.mainContext,
            account: gitHubAccount
        )
        lastPollDate = nil
        lastMarkedAllReadDate = nil
        rateLimitSummary = "Not checked"

        if enableGlobalShortcuts {
            configureGlobalShortcuts()
        }

        Task {
            await gitHubAccount.restoreSession()
            if gitHubAccount.status.isConnected {
                await refreshAuthoredPullRequests()
            }
        }
    }

    public func refreshAuthoredPullRequests() async {
        await pullRequestSync.refreshAuthoredPullRequests()
        lastPollDate = Date()
        if let error = pullRequestSync.lastErrorMessage {
            rateLimitSummary = error
        } else {
            rateLimitSummary = "OK"
        }
    }

    public func showSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }

    private func configureGlobalShortcuts() {
        let quickPopover = QuickPopoverWindowController(appState: self, container: container)
        let globalShortcuts = GlobalShortcutService()

        globalShortcuts.registerDefaults(
            openPopover: { [weak self] in
                self?.quickPopover?.toggle()
            },
            refresh: { [weak self] in
                Task {
                    await self?.refreshAuthoredPullRequests()
                }
            },
            markAllRead: { [weak self] in
                self?.lastMarkedAllReadDate = Date()
            },
            openSettings: {
                self.showSettingsWindow()
            }
        )

        self.quickPopover = quickPopover
        self.globalShortcuts = globalShortcuts
    }
}
