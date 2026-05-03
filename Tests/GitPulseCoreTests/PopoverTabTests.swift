import Testing
@testable import GitPulseCore

@Suite("Popover filters")
struct PopoverTabTests {
    @Test("popover exposes corrected activity filters")
    func popoverFiltersMatchSpec() {
        #expect(FeedFilter.allCases == [.all, .prs, .issues, .cicd, .mentions])
        #expect(FeedFilter.cicd.label == "ci/cd")
    }
}
