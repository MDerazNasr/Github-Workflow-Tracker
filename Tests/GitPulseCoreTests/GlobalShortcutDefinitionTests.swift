import Testing
@testable import GitPulseCore

@Suite("Global shortcut definitions")
struct GlobalShortcutDefinitionTests {
    @Test("default shortcuts cover each global action once")
    func defaultsCoverActions() {
        let actions = Set(GlobalShortcutDefinition.defaults.map(\.action))

        #expect(actions == Set(GlobalShortcutAction.allCases))
        #expect(GlobalShortcutDefinition.defaults.count == GlobalShortcutAction.allCases.count)
    }

    @Test("default shortcut display strings match settings defaults")
    func displayStringsMatchDefaults() {
        let displays = Dictionary(
            uniqueKeysWithValues: GlobalShortcutDefinition.defaults.map { ($0.action, $0.displayString) }
        )

        #expect(displays[.openPopover] == "⌥ Space")
        #expect(displays[.refresh] == "⌥ R")
        #expect(displays[.markAllRead] == "⌥ M")
        #expect(displays[.openSettings] == "⌥ ,")
    }
}
