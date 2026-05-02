import Testing
@testable import GitPulseCore

@Suite("Settings window")
struct SettingsWindowTests {
    @Test("sidebar only exposes active settings sections")
    func sidebarSectionsAreActionable() {
        #expect(SettingsSection.allCases.map(\.label) == [
            "General",
            "Account",
            "Notifications",
            "Polling",
            "Popover",
            "Shortcuts",
            "Advanced"
        ])
    }

    @Test("feed filters follow visible activity settings")
    func feedFiltersFollowVisibleActivitySettings() {
        let settings = AppSettings()
        settings.tabIssuesEnabled = true
        settings.tabCICDEnabled = false
        settings.tabMentionsEnabled = true

        #expect(FeedFilter.visibleFilters(settings: settings) == [.all, .prs, .issues, .mentions])
        #expect(!FeedFilter.cicd.isEnabled(in: settings))
        #expect(FeedFilter.mentions.isEnabled(in: settings))
    }

    @Test("demo activity covers supported activity filters")
    func demoActivityCoversSupportedActivityFilters() {
        let filters = Set(DemoWorkflowEvent.samples().map(\.filter))

        #expect(filters == Set([.prs, .issues, .cicd, .mentions]))
    }
}
