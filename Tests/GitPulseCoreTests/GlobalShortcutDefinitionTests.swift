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

    @Test("parser accepts custom shortcut strings")
    func parserAcceptsCustomShortcuts() {
        let definition = GlobalShortcutDefinition.parse(
            action: .refresh,
            displayString: "⌃ ⌥ P"
        )

        #expect(definition?.action == .refresh)
        #expect(definition?.displayString == "⌃ ⌥ P")
        #expect(definition?.keyCode == 35)
    }

    @Test("parser rejects shortcuts without modifiers")
    func parserRejectsMissingModifiers() {
        let definition = GlobalShortcutDefinition.parse(
            action: .refresh,
            displayString: "P"
        )

        #expect(definition == nil)
    }

    @Test("settings definitions fall back per invalid shortcut")
    func settingsDefinitionsFallBackForInvalidValues() {
        let settings = AppSettings()
        settings.shortcutRefresh = "not a shortcut"

        let definitions = GlobalShortcutDefinition.definitions(from: settings)
        let refresh = definitions.first { $0.action == .refresh }

        #expect(refresh?.displayString == "⌥ R")
    }
}
