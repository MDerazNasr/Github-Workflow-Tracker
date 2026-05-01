import Testing
@testable import GitPulseCore

@Suite("Settings window")
struct SettingsWindowTests {
    @Test("sidebar only exposes active settings sections")
    func sidebarSectionsAreActionable() {
        #expect(SettingsSection.allCases.map(\.label) == [
            "General",
            "Account",
            "Polling",
            "Popover",
            "Shortcuts",
            "Advanced"
        ])
    }
}
