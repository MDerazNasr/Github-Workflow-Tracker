import Testing
@testable import GitPulseCore

@Suite("Popover tabs")
struct PopoverTabTests {
    @Test("popover exposes activity and compact settings tabs")
    func popoverTabsMatchUISplit() {
        #expect(PopoverTab.allCases == [.activity, .settings])
        #expect(PopoverTab.activity.label == "Activity")
        #expect(PopoverTab.settings.label == "Settings")
    }
}
