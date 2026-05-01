import SwiftData
import Testing
@testable import GitPulseCore

@MainActor
@Suite("App settings")
struct AppSettingsTests {
    @Test("ensureExists creates exactly one singleton settings row")
    func ensureExistsCreatesSingleton() throws {
        let container = try makeContainer()
        let context = container.mainContext

        AppSettings.ensureExists(in: context)
        AppSettings.ensureExists(in: context)

        let settings = try context.fetch(FetchDescriptor<AppSettings>())
        #expect(settings.count == 1)
        #expect(settings.first?.id == "singleton")
    }

    @Test("quiet hours handles overnight ranges")
    func quietHoursSupportsOvernightRanges() {
        let settings = AppSettings()
        settings.quietHoursEnabled = true
        settings.quietHoursFrom = 22
        settings.quietHoursTo = 6

        #expect(settings.isQuietHoursActive(atHour: 23))
        #expect(settings.isQuietHoursActive(atHour: 2))
        #expect(!settings.isQuietHoursActive(atHour: 14))
    }

    @Test("poll interval falls back to one minute for unknown values")
    func pollIntervalFallback() {
        let settings = AppSettings()

        settings.pollIntervalSeconds = 12345

        #expect(settings.pollInterval == .oneMinute)
    }

    @Test("reset restores documented defaults")
    func resetRestoresDefaults() {
        let settings = AppSettings()
        settings.defaultTab = "issues"
        settings.fontSize = 16
        settings.notificationsEnabled = false
        settings.webhookEnabled = true
        settings.menuBarCountCap = 0
        settings.popoverWidth = 560

        settings.resetToDefaults()

        #expect(settings.defaultTab == "activity")
        #expect(settings.fontSize == 13)
        #expect(settings.notificationsEnabled)
        #expect(!settings.webhookEnabled)
        #expect(settings.menuBarCountCap == 99)
        #expect(settings.popoverWidth == 420)
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
