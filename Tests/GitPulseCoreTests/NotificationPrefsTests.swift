import SwiftData
import Testing
@testable import GitPulseCore

@MainActor
@Suite("Notification preferences")
struct NotificationPrefsTests {
    @Test("ensureDefaults creates one preference row per notifiable event type")
    func ensureDefaultsCreatesRows() throws {
        let schema = Schema([
            AppSettings.self,
            NotificationPrefs.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = container.mainContext

        NotificationPrefs.ensureDefaults(in: context)
        NotificationPrefs.ensureDefaults(in: context)

        let prefs = try context.fetch(FetchDescriptor<NotificationPrefs>())
        #expect(prefs.count == EventType.allNotifiableCases.count)
    }
}
