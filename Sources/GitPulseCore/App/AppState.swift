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
    public private(set) var statusItemPopover: StatusItemPopoverController?
    private var settingsWindowController: SettingsWindowController?
    public var lastPollDate: Date?
    public var lastMarkedAllReadDate: Date?
    public var rateLimitSummary: String

    public init(inMemory: Bool = false, enableGlobalShortcuts: Bool = true) {
        AppIconService.applyAppIcon()
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

        if let settings = currentSettings() {
            applyRuntimeSettings(settings)
        }
        statusItemPopover = StatusItemPopoverController(appState: self, container: container)
        if enableGlobalShortcuts {
            configureGlobalShortcuts()
        }
        settingsWindowController = SettingsWindowController(appState: self, container: container)

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
        settingsWindowController?.show()
    }

    public func reloadGlobalShortcuts() {
        guard globalShortcuts != nil else {
            return
        }
        configureGlobalShortcuts()
    }

    func applyRuntimeSettings(_ settings: AppSettings) {
        NSApp.setActivationPolicy(settings.showInDock ? .regular : .accessory)
        NSApp.appearance = settings.appearance.nsAppearance
        settingsWindowController?.applyAppearance(settings.appearance)
    }

    private func configureGlobalShortcuts() {
        let globalShortcuts = GlobalShortcutService()
        let settings = currentSettings()
        let definitions = settings.map(GlobalShortcutDefinition.definitions(from:)) ?? GlobalShortcutDefinition.defaults

        self.globalShortcuts?.unregisterAll()
        globalShortcuts.register(
            definitions: definitions,
            openPopover: { [weak self] in
                self?.statusItemPopover?.toggle()
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

        self.globalShortcuts = globalShortcuts
    }

    private func currentSettings() -> AppSettings? {
        try? container.mainContext.fetch(FetchDescriptor<AppSettings>()).first
    }
}
